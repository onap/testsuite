from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
import re
from typing import Iterable


ROOT = Path(__file__).resolve().parent.parent
TESTSUITES_DIR = ROOT / "robot" / "testsuites"
DOCS_DIR = ROOT / "docs"
SUITES_DOCS_DIR = DOCS_DIR / "suites"

SECTION_PATTERN = re.compile(r"^\*{3}\s*(.+?)\s*\*{3}(.*)$")
SPLIT_PATTERN = re.compile(r"\t+|\s{2,}")


@dataclass
class SuiteMeta:
    relative_path: str
    documentation: list[str] = field(default_factory=list)
    timeout: str | None = None
    test_template: str | None = None
    force_tags: list[str] = field(default_factory=list)


@dataclass
class TestCase:
    name: str
    arguments: list[str] = field(default_factory=list)
    documentation: list[str] = field(default_factory=list)
    tags: list[str] = field(default_factory=list)
    timeout: str | None = None
    setup: str | None = None
    teardown: str | None = None
    template: str | None = None
    step_count: int = 0
    first_step: str | None = None


def split_columns(text: str) -> list[str]:
    stripped = text.strip()
    if stripped.startswith("|"):
        return [segment.strip() for segment in stripped.split("|") if segment.strip()]
    return [segment.strip() for segment in SPLIT_PATTERN.split(text.strip()) if segment.strip()]


def escape_inline(text: str) -> str:
    return text.replace("`", "\\`")


def parse_suite(path: Path) -> tuple[SuiteMeta, list[TestCase], list[str]]:
    lines = path.read_text(encoding="utf-8").splitlines()
    meta = SuiteMeta(relative_path=str(path.relative_to(ROOT)).replace("\\", "/"))
    test_cases: list[TestCase] = []
    test_case_headers: list[str] = []

    current_section = ""
    current_case: TestCase | None = None
    pending_setting_doc = False
    pending_case_doc = False

    for raw_line in lines:
        stripped = raw_line.strip()
        section_match = SECTION_PATTERN.match(stripped)
        if section_match:
            section_name = section_match.group(1).lower()
            trailing = section_match.group(2).strip()
            current_section = section_name
            if section_name == "test cases" and trailing:
                test_case_headers = split_columns(trailing)
            current_case = None
            pending_setting_doc = False
            pending_case_doc = False
            continue

        if current_section == "settings":
            if not stripped or stripped.startswith("#"):
                pending_setting_doc = False
                continue
            if stripped.startswith("..."):
                continuation_text = stripped[3:].strip()
                if pending_setting_doc and continuation_text:
                    meta.documentation.append(continuation_text)
                continue

            cols = split_columns(raw_line)
            if not cols:
                continue
            key = cols[0].lower()
            value = " ".join(cols[1:]).strip()

            if key == "documentation":
                pending_setting_doc = True
                if value:
                    meta.documentation.append(value)
            else:
                pending_setting_doc = False
                if key == "test timeout" and value:
                    meta.timeout = value
                elif key == "test template" and value:
                    meta.test_template = value
                elif key == "force tags":
                    meta.force_tags.extend(cols[1:])

            continue

        if current_section != "test cases":
            continue

        if not stripped:
            pending_case_doc = False
            continue
        if stripped.startswith("#"):
            continue

        is_new_case = (
            not raw_line.startswith((" ", "\t"))
            and not stripped.startswith("...")
            and not stripped.startswith("|")
        )
        if is_new_case:
            cols = split_columns(raw_line)
            if not cols:
                continue
            current_case = TestCase(name=cols[0], arguments=cols[1:])
            test_cases.append(current_case)
            pending_case_doc = False
            continue

        if current_case is None:
            continue

        indented = raw_line.lstrip()
        if indented.startswith("..."):
            continuation_text = indented[3:].strip()
            if pending_case_doc and continuation_text:
                current_case.documentation.append(continuation_text)
            continue

        cols = split_columns(indented)
        if not cols:
            continue

        first = cols[0]
        if first.startswith("[") and first.endswith("]"):
            setting_name = first[1:-1].lower()
            value_cols = cols[1:]
            if setting_name == "documentation":
                pending_case_doc = True
                if value_cols:
                    current_case.documentation.append(" ".join(value_cols))
            else:
                pending_case_doc = False
                if setting_name == "tags":
                    current_case.tags.extend(value_cols)
                elif setting_name == "timeout" and value_cols:
                    current_case.timeout = " ".join(value_cols)
                elif setting_name == "setup" and value_cols:
                    current_case.setup = " ".join(value_cols)
                elif setting_name == "teardown" and value_cols:
                    current_case.teardown = " ".join(value_cols)
                elif setting_name == "template" and value_cols:
                    current_case.template = " ".join(value_cols)
            continue

        pending_case_doc = False
        current_case.step_count += 1
        step_text = " ".join(cols)
        if current_case.first_step is None:
            current_case.first_step = step_text

    return meta, test_cases, test_case_headers


def title_block(text: str, marker: str = "=") -> str:
    line = marker * len(text)
    return f"{text}\n{line}\n"


def render_suite_page(meta: SuiteMeta, test_cases: list[TestCase], headers: list[str]) -> str:
    page_title = f"Suite: {meta.relative_path}"
    parts: list[str] = [title_block(page_title)]

    parts.append("Suite Metadata\n--------------\n")
    parts.append(f"- **Source file:** ``{escape_inline(meta.relative_path)}``")
    if meta.documentation:
        parts.append(f"- **Suite documentation:** {escape_inline(' '.join(meta.documentation))}")
    if meta.timeout:
        parts.append(f"- **Default test timeout:** ``{escape_inline(meta.timeout)}``")
    if meta.test_template:
        parts.append(f"- **Suite test template:** ``{escape_inline(meta.test_template)}``")
    if meta.force_tags:
        tags = ", ".join(f"``{escape_inline(tag)}``" for tag in meta.force_tags)
        parts.append(f"- **Force tags:** {tags}")
    parts.append(f"- **Total test cases:** {len(test_cases)}\n")

    parts.append("Test Cases\n----------\n")

    if not test_cases:
        parts.append("This suite defines no explicit test cases.\n")
        return "\n".join(parts)

    if headers:
        table_headers = ", ".join(f"``{escape_inline(h)}``" for h in headers)
        parts.append(f"Template argument headers declared in suite: {table_headers}.\n")

    for case in test_cases:
        case_title = case.name
        parts.append(title_block(case_title, "~"))
        if case.documentation:
            parts.append(f"**Documentation:** {escape_inline(' '.join(case.documentation))}\n")

        parts.append("- **Name:** ``%s``" % escape_inline(case.name))
        if case.arguments:
            rendered_args = ", ".join(f"``{escape_inline(arg)}``" for arg in case.arguments)
            parts.append(f"- **Template arguments:** {rendered_args}")
        if case.tags:
            rendered_tags = ", ".join(f"``{escape_inline(tag)}``" for tag in case.tags)
            parts.append(f"- **Tags:** {rendered_tags}")
        if case.timeout:
            parts.append(f"- **Timeout:** ``{escape_inline(case.timeout)}``")
        if case.setup:
            parts.append(f"- **Setup:** ``{escape_inline(case.setup)}``")
        if case.teardown:
            parts.append(f"- **Teardown:** ``{escape_inline(case.teardown)}``")
        if case.template:
            parts.append(f"- **Case template override:** ``{escape_inline(case.template)}``")
        parts.append(f"- **Step count:** {case.step_count}")
        if case.first_step:
            parts.append(f"- **First step:** ``{escape_inline(case.first_step)}``")
        parts.append("")

    improvements = build_improvement_suggestions(meta, test_cases)
    parts.append("Possible Improvements\n---------------------\n")
    for suggestion in improvements:
        parts.append(f"- {suggestion}")
    parts.append("")

    return "\n".join(parts)


def build_improvement_suggestions(meta: SuiteMeta, test_cases: list[TestCase]) -> list[str]:
    suggestions: list[str] = []
    suite_path = meta.relative_path.lower()

    tests_without_docs = [case for case in test_cases if not case.documentation]
    tests_without_tags = [case for case in test_cases if not case.tags]
    long_tests = [case for case in test_cases if case.step_count >= 8]
    zero_step_cases = [case for case in test_cases if case.step_count == 0]
    custom_timeouts = [case for case in test_cases if case.timeout]

    if not meta.documentation:
        suggestions.append("Add suite-level `Documentation` to clarify target subsystem, prerequisites, and expected environment.")
    else:
        suggestions.append("Keep suite documentation aligned with current ONAP release behavior and update references when endpoints or flows change.")

    if tests_without_docs:
        suggestions.append(
            f"Add `[Documentation]` to {len(tests_without_docs)} test case(s) to explain intent, preconditions, and expected outcome."
        )
    else:
        suggestions.append("Continue maintaining per-test `[Documentation]` blocks with concise failure diagnostics and expected assertions.")

    if tests_without_tags:
        suggestions.append(
            f"Tag the {len(tests_without_tags)} untagged test case(s) so selective execution (`--include`/`--exclude`) remains predictable."
        )
    else:
        suggestions.append("Review tag naming consistency (for example `health-*`, `instantiate*`, `ete`) to keep filtering and reporting uniform.")

    if long_tests:
        suggestions.append(
            f"Refactor {len(long_tests)} long test case(s) into reusable user keywords to reduce maintenance cost and improve readability."
        )

    if zero_step_cases and meta.test_template:
        suggestions.append(
            "For template-driven cases, add short per-case documentation so intent is visible without reading the template implementation."
        )
    elif zero_step_cases:
        suggestions.append(
            "Investigate zero-step test entries and ensure they are intentional (not formatting artifacts), with explicit validation steps where needed."
        )

    if custom_timeouts and not meta.timeout:
        suggestions.append("Consider defining a suite-level `Test Timeout` baseline and keep only justified per-test overrides.")

    if "health-check" in suite_path:
        suggestions.append("Split broad health checks into component-focused suites to reduce blast radius and simplify parallel execution.")
    if "vnf-orchestration" in suite_path:
        suggestions.append("Externalize environment-specific input values into variable files to reduce hard-coded orchestration parameters.")
    if "model-distribution" in suite_path:
        suggestions.append("Add explicit post-distribution verification assertions to prove model availability in target consumers.")
    if "portal" in suite_path:
        suggestions.append("Stabilize UI tests by preferring resilient locators and explicit waits over timing assumptions.")
    if "security" in suite_path:
        suggestions.append("Add negative-path assertions (missing/extra ports, malformed files) to strengthen security validation coverage.")
    if "usecases" in suite_path:
        suggestions.append("Document required external dependencies and data contracts (topics, endpoints, credentials) for faster troubleshooting.")

    if len(suggestions) < 4:
        suggestions.append("Add teardown cleanup checks so repeated runs are idempotent and less sensitive to residual state.")

    return suggestions


def ensure_base_docs() -> None:
    DOCS_DIR.mkdir(parents=True, exist_ok=True)
    SUITES_DOCS_DIR.mkdir(parents=True, exist_ok=True)

    conf = """project = 'testsuite Test Case Documentation'
author = 'Auto-generated from Robot Framework suites'
extensions = []
templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']
html_theme = 'alabaster'
"""
    (DOCS_DIR / "conf.py").write_text(conf, encoding="utf-8")

    overview = """Repository Test Documentation
=============================

This Sphinx documentation set is generated from Robot Framework test suites located under ``robot/testsuites``.

Generation
----------

Run the generator script from the repository root:

.. code-block:: bash

   python docs/generate_robot_docs.py

Then build Sphinx docs:

.. code-block:: bash

   sphinx-build -b html docs docs/_build/html
"""
    (DOCS_DIR / "overview.rst").write_text(overview, encoding="utf-8")


def suite_doc_name(relative_robot_path: str) -> str:
    return relative_robot_path.replace("/", "__").replace(".robot", "")


def iter_suite_files() -> Iterable[Path]:
    for path in sorted(TESTSUITES_DIR.rglob("*.robot")):
        content = path.read_text(encoding="utf-8")
        if re.search(r"^\*\*\*\s*Test Cases\s*\*\*\*", content, flags=re.MULTILINE):
            yield path


def generate() -> tuple[int, int]:
    ensure_base_docs()

    for old_file in SUITES_DOCS_DIR.glob("*.rst"):
        old_file.unlink()

    suite_entries: list[tuple[str, str, int]] = []
    total_cases = 0

    for suite_path in iter_suite_files():
        meta, test_cases, headers = parse_suite(suite_path)
        total_cases += len(test_cases)
        doc_stem = suite_doc_name(meta.relative_path)
        suite_doc_path = SUITES_DOCS_DIR / f"{doc_stem}.rst"
        suite_doc_path.write_text(render_suite_page(meta, test_cases, headers), encoding="utf-8")
        suite_entries.append((doc_stem, meta.relative_path, len(test_cases)))

    suites_index_parts = [title_block("Test Suites", "="), ".. toctree::", "   :maxdepth: 1", "", ""]
    for doc_stem, _, _ in suite_entries:
        suites_index_parts.append(f"   {doc_stem}")
    suites_index_parts.append("")
    suites_index_parts.append("Suite Coverage Summary")
    suites_index_parts.append("----------------------")
    suites_index_parts.append("")
    suites_index_parts.append(f"- **Total suites documented:** {len(suite_entries)}")
    suites_index_parts.append(f"- **Total test cases documented:** {total_cases}")
    suites_index_parts.append("")
    for _, rel_path, count in suite_entries:
        suites_index_parts.append(f"- ``{escape_inline(rel_path)}``: {count} test case(s)")
    suites_index_parts.append("")
    (SUITES_DOCS_DIR / "index.rst").write_text("\n".join(suites_index_parts), encoding="utf-8")

    root_index = """testsuite Test Case Documentation
=================================

.. toctree::
   :maxdepth: 2
   :caption: Contents

   overview
   suites/index
"""
    (DOCS_DIR / "index.rst").write_text(root_index, encoding="utf-8")

    return len(suite_entries), total_cases


if __name__ == "__main__":
    suite_count, case_count = generate()
    print(f"Generated documentation for {suite_count} suites and {case_count} test cases in {DOCS_DIR}")
Repository Test Documentation
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

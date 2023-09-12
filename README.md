# README FIRST

This container has been rebased to python 3.9 and pulls from upstream UBI repos.

This container now makes use of a python virtual environment as is best practice.  You can use this container as-is to run basic Python 3.9 code.  If your code requires additional modules, then you will have to inject a new requirements.txt file and trigger an install via pip.  The easiest way to do this is create a new Dockefile that uses this image in the FROM line, copy in your requirements.txt, activate the python virtual environment ("source python-env/bin/activate") and do a pip install of your requirements.txt file.

To use the python virtual environment and it's installed modules, invoke python with an entrypoint.sh script that looks like this:

```
#!/usr/bin/env bash

source python-env/bin/activate 
source /home/python/.bash_profile

/path/to/your/command --and --its --arguments
```

# python39
Python is developed under an OSI-approved open source license, making it freely usable and distributable, even for commercial use. Python's license is administered by the Python Software Foundation.

Connect to [https://www.python.org/](https://www.python.org/)for complete details about Python.

# More resources
Python 3.9 Online Documentation at [https://docs.python.org/3.9/](https://docs.python.org/3.9/)
Report bugs at [https://bugs.python.org](https://bugs.python.org).


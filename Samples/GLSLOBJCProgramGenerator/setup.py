
from setuptools import setup, find_packages

# http://docs.python.org/distutils/setupscript.html#additional-meta-data

setup(
	name = 'GLSLOBJCProgramGenerator',
	version = '0.1.1dev',

	install_requires = ['genshi >= 0.5'],
	packages = find_packages(exclude = [ 'ez_setup', 'tests' ]),
	package_data = { '': ['templates/*'] },
	include_package_data = True,
	scripts = ['scripts/GLSLOBJCProgramGenerator'],
	zip_safe = True,
	author = 'Jonathan Wight',
	author_email = 'jwight@mac.com',
	classifiers = [
		'Development Status :: 3 - Alpha',
		'Environment :: MacOS X :: Cocoa',
		'Intended Audience :: Developers',
		'License :: OSI Approved :: BSD License',
		'Operating System :: MacOS :: MacOS X',
		'Programming Language :: Objective C',
		'Topic :: Software Development :: Build Tools',
		],
	description = 'TODO',
	license = 'BSD License',
	long_description = file('README.txt').read(),
	platform = 'Mac OS X',
	url = 'TODO',
	)


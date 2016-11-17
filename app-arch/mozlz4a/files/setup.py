"""
setuptools configuration for mozlz4a

"""


import os
import sys
import setuptools


NAME = 'mozlz4a'
DESCRIPTION = 'MozLz4a compression/decompression utility.'
AUTHOR = 'Tilman Blumenbach'
URL = 'https://gist.github.com/Tblue/62ff47bef7f894e92ed5'
LICENSE = 'GPLv2'
CLASSIFIERS = [
    'Development Status :: 4 - Beta',
    'Intended Audience :: Developers',
    'License :: OSI Approved :: GNU General Public License v2 (GPLv2)',
    'Operating System :: POSIX :: Linux',
    'Programming Language :: Python :: 3.4',
    'Programming Language :: Python :: Implementation :: CPython',
    'Topic :: System :: Archiving :: Compression',
]


data = dict(
    name=NAME,
    description=DESCRIPTION,
    url=URL,
    author=AUTHOR,
    license=LICENSE,
    packages=['mozlz4a'],
    entry_points={'console_scripts': ['mozlz4a=mozlz4a:main']},
    install_requires=['lz4'],
    classifiers=CLASSIFIERS,
)

if __name__ == '__main__':
    setuptools.setup(**data)

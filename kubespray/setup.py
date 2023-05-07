import setuptools

setuptools.setup(
    name="mypackage",
    version="0.1.0",
    author="John Doe",
    author_email="johndoe@example.com",
    description="My awesome package",
    packages=setuptools.find_packages(),
    install_requires=[
        # Список зависимостей из requirements.txt
        dependency.strip() for dependency in open("kubespray/requirements.txt").readlines()
    ],
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.6",
)

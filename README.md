Digital Edition of Fernando Pessoa
======
Projects and Publications
======

This is the Github repository accompanying the Digital Edition of Fernando Pessoa's Projects and Publications.

Resulting from a collaboration between researchers of the Estranging Pessoa research project, based in IELT (Institute for the Study of Literature and Tradition), New University of Lisbon, and the CCeH (Cologne Center for eHumanities), University of Cologne, the digital edition aims at offering a unique access to the documents of Fernando Pessoa’s work.

The results of this work will be published on http://projects.cceh.uni-koeln.de/pessoa in February 2017.


<!-- MarkdownTOC -->

- [Workflow](#workflow)
- [Setting up the development environment](#setting-up-the-development-environment)
	- [Install git](#install-git)
	- [Install eXist-db](#install-exist-db)
	- [Install Node.js](#install-nodejs)
		- [On Windows:](#on-windows)
		- [On Mac:](#on-mac)
		- [On Linux](#on-linux)
	- [Getting the source code](#getting-the-source-code)
	- [Installing the development tools](#installing-the-development-tools)
	- [Installing the webapp dependencies](#installing-the-webapp-dependencies)
	- [Configuring deployment to eXist](#configuring-deployment-to-exist)
	- [Deploying the app to your local eXist](#deploying-the-app-to-your-local-exist)
	- [Creating the index](#creating-the-index)
- [Working with gulp](#working-with-gulp)
	- [Watchers](#watchers)
	- [Deployment](#deployment)
	- [Indexing](#indexing)
	- [Creating a XAR archive](#creating-a-xar-archive)

<!-- /MarkdownTOC -->


<a name="workflow"></a>
## Workflow

Development for the Pessoa edition is done using a local eXist instance. You will work on a local copy of the source code 
which is deployed to your local eXist after every change you want to test. Please do not use the eXist
feature of the Oxygen editor to directly modifiy the files inside the database as this will inevitably lead 
to chaos when working collaboratively using git.

By using the gulp watch task as described below, this is really more convenient than it sounds.

<a name="setting-up-the-development-environment"></a>
## Setting up the development environment

<a name="install-git"></a>
### Install git

* On Linux: Use your package manager
* On Mac: git comes pre-installed
* On Windows: Install (Git for Windows)[https://git-scm.com/download/win] and preferably choose "Use Git from the Windows Command Prompt" during installation

<a name="install-exist-db"></a>
### Install eXist-db

You will need to have installed Java 7 or higher.

Get *eXist-db 2.2* from [here](http://exist-db.org/exist/apps/homepage/index.html). For Mac, run the installer in the .dmg file. For Windows and Linux, get the .jar, open up a terminal and run

```sh
java -jar exist-db-setup-2.2.jar
```

<a name="install-nodejs"></a>
### Install Node.js

The Node.js package manager ```npm``` is used to manage the development tools. 

<a name="on-windows"></a>
#### On Windows:

Get it [here](https://nodejs.org/en/) and install the package.

<a name="on-mac"></a>
#### On Mac:

The *preferred* way:

1. Install the [Homebrew](http://brew.sh/) package manager
2. Install node:

	```sh
	brew install node
	```

The *other* way:

* Download it from [here](https://nodejs.org/en/) and install the package

<a name="on-linux"></a>
#### On Linux

You are using Linux. You'll find out how to install node.js


<a name="getting-the-source-code"></a>
### Getting the source code

```sh
git clone https://github.com/cceh/pessoa
```


<a name="installing-the-development-tools"></a>
### Installing the development tools

We are going to install **gulp** which will be our build and deployment tool, and **bower**, which will manage the dependencies of our webapp like bootstrap and jquery.

```sh
cd pessoa

# globally install gulp and bower
npm install -g gulp

# locally install development dependencies
npm install
```

The last command will read the dev dependencies specified in ```package.json``` and install them inside ```node_modules```. 

<a name="installing-the-webapp-dependencies"></a>

### Configuring deployment to eXist

Copy the deployment configuration from the [internal Wiki](https://wiki.uni-koeln.de/cceh/index.php/Pessoa-Projekt) and save it as ```exist-secrets.js```

If your local eXist configuration differs, adjust accordingly.

<a name="updating-dependencies"></a>


<a name="deploying-the-app-to-your-local-exist"></a>
### Deploying the app to your local eXist

Now you should have everything together to deploy the pessoa app to your local eXist 

```sh
gulp deploy-local
```

<a name="creating-the-index"></a>
### Creating the index

The Pessoa app needs a working database index. Use

```sh
gulp update-index
```

to create it.

Everytime there is a change in ```collection.xconf```, (e.g. after a ```git pull```), you need to update the index using this command.

If there was no error, you should have a working pessoa instance at http://localhost:8080/exist/apps/pessoa (or similar).


<a name="working-with-gulp"></a>
## Working with gulp

During development, you will be using the gulp build tool to run common tasks.

<a name="watchers"></a>
### Watchers

This is a huge time saver during development. Open up a terminal and run

```sh
gulp watch
```

Now edit a source file, save it and watch it magically being uploaded to eXist! This will also work for SCSS files, which are automatically compiled and then uploaded.

<a name="deployment"></a>
### Deployment

Everytime you edited something (and you are not using the watcher) or pulled new code from git, you need to deploy it to your local eXist instance by running 

```sh
gulp deploy-local
```
This will process everything in the ```./app``` folder and copy the resulting files to ```./build```.
Only files that are newer than the ones already in the eXist database are uploaded. If you desperately want to re-upload a file, you can use (on Mac or Linux or Windows with bash):

```sh
touch path/to/file.xml
gulp deploy-local
```

*Note*: eXist 2.2 has an annoying bug that causes it to freeze occasionally when uploading an XQuery file. If you see an upload taking a unusually long time, kill and restart eXist-db. Then get some coffee while eXist will run its recovery and reindex all database files. You also need to restart ```gulp watch```if that happens.

<a name="indexing"></a>
### Indexing

Use

```sh
gulp update-index
```
to re-create the index when you have modified ```collection.xconf```.

<a name="creating-a-xar-archive"></a>

### Creating a XAR archive

In case you want to build a xar archive that can be imported into eXist using the package manager, use

```sh
gulp xar
```




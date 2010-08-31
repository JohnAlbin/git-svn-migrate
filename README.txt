ABOUT git-svn-migrate
---------------------

Helper scripts to ease the migration of Subversion repositories to Git.

The basic steps to converting a list of Subversion repositories into Git
repositories is the following:

1. Create a list of Subversion repositories to convert.

2. Retrieve a list of Subversion committers with:
   ./fetch-svn-author.sh  --url-file=[filename] > [output file for raw authors]

3. Edit the raw list of Subverions committers to provide full names and emails.

4. Convert the Subverion repositories into bare Git repositories with:
   ./git-svn-migrate.sh --url-file=[filename] --authors-file=[filename] [destination folder]


USAGE
-----

1. Create a list of Subversion repositories to convert.

The repository list can be in two forms. The simplest form is simply one URL per
line:

  svn+ssh://example.org/svn/awesomeProject
  file:///svn/secretProject
  https://example.com/svn/evilProject

With this format the name of the project is assumed to be the last part of the
URL. So these repostitories would be converted into awesomeProject.git,
secretProject.git and evilProject.git, respectively.

If the project name of your repository is not the last part of the URL, or you
wish to have more control over the name of the Git repository, you can specify
the repository list in tab-delimited format with the first field being the name
to give the Git repository and the second field being the URL of the Subversion
repository:

  awesomeProject    svn+ssh://example.org/svn/awesomeProject/repo
  secretProject     file:///svn/secretProject
  notSoEvilProject  https://example.com/svn/evilestProjectEver

2. Retrieve a list of Subversion committers with:

Using the repository list created in step 1, run the fetch-svn-author.sh script
to create a list of unique usernames for all the commits in your repositories.
The output of the script should be redirected to a file.

Example:

  $ ./fetch-svn-author.sh --url-file=repository-list.txt > authors-raw.txt

3. Edit the raw list of Subverions committers to provide full names and emails.

The output of the fetch-svn-author.sh script will be of the form:
  username = username <username>
You should edit each line to be:
  username = Full name <email>
For example:
  jwilkins = John Albin Wilkins <john@example.org>

4. Convert the Subverion repositories into bare Git repositories.

Example:

  $ ./git-svn-migrate.sh --url-file=repository-list.txt --authors-file=authors.txt /var/git

NOTE: Due to a minor bug/limitation, you'll need to run the script from within
the folder containing the git-svn-migrate.sh script.


AUTHENTICATION
--------------

Authenticating with each of the repositories is out-of-scope for these scripts.
You should ensure that all of the SVN repositories can be accessed
non-interactively (i.e. no password prompts) in order for these scripts to work.


LICENSE
-------

Available under the GPL v2 license. See LICENSE.txt.

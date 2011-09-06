ABOUT git-svn-migrate
---------------------

The git-svn-migrate project is a set of helper scripts to ease the migration of
Subversion repositories to Git.

The basic steps to converting a list of Subversion repositories into Git
repositories are the following:

1. Create a list of Subversion repositories to convert.

2. Create a list of transformations for Subversion usernames to Git committers.
   Run:
   ./fetch-svn-authors.sh  --url-file=[filename] > [output file for raw authors]

   Then edit the raw list of Subversion usernames to provide full names and
   emails suitable for Git committers.

3. Convert the Subversion repositories into bare Git repositories with:
   ./git-svn-migrate.sh --url-file=[filename] --authors-file=[filename] [destination folder]

A blog post about these migration scripts and a blog post about the underlying
techniques are available at:
http://john.albin.net/git/git-svn-migrate
http://john.albin.net/git/convert-subversion-to-git


USAGE
-----

1. Create a list of Subversion repositories to convert.

The repository list should just be a plain text file with one repository per
line. Each line can be in one of two formats. The basic format is simply the
repository's URL by itself:

  svn+ssh://example.org/svn/awesomeProject
  file:///svn/secretProject
  https://example.com/svn/evilProject

With this format the name of the project is assumed to be the last part of the
URL. So these repositories would be converted into awesomeProject.git,
secretProject.git and evilProject.git, respectively.

If the project name of your repository is not the last part of the URL, or you
wish to have more control over the final name of the Git repository, you can
specify the repository list in tab-delimited format with the first field being
the name to give the Git repository and the second field being the URL of the
Subversion repository:

  awesomeProject    svn+ssh://example.org/svn/awesomeProject/repo
  evilproject     file:///svn/evilProject
  notthedroidsyourlookingfor  https://example.com/svn/secretProject

With this format you can use any name for the final Git repo. In the first
example above, we're using the second-to-last part of the URL instead of the
last part of the URL. In the second example, we're just changing the name to all
lowercase (recommended). And in the final example, move along. Move along.

2. Create a list of transformations for Subversion usernames to Git committers.

Using the repository list created in step 1, run the fetch-svn-authors.sh script
to create a list of unique usernames for all the commits in your repositories.
The output of the script should be redirected to a file.

Example (assuming your repository list is in "repository-list.txt"):

  $ ./fetch-svn-authors.sh --url-file=repository-list.txt > author-transform.txt

Edit the raw list of Subversion usernames to provide full names and emails
suitable for Git committers. The output of the fetch-svn-authors.sh script will
be of the form:
  username = username <username>
You should edit each line to be:
  username = Full name <email>

For example:
  change:
    jwilkins = jwilkins <jwilkins>
  into:
    jwilkins = John Albin Wilkins <john@example.org>

You can run "./fetch-svn-authors.sh --help" to get full documentation on the
options it accepts.

3. Convert the Subversion repositories into bare Git repositories.

Example:

  $ ./git-svn-migrate.sh --url-file=repository-list.txt --authors-file=author-transform.txt /var/git

You can run "./git-svn-migrate.sh --help" to get full documentation on the
options it accepts.


AUTHENTICATION
--------------

Authenticating with each of the repositories is out-of-scope for these scripts.
You should ensure that all of the SVN repositories can be accessed
non-interactively (i.e. no password prompts) in order for these scripts to work.
If you consider this a bug, bugfixes are welcome!


REQUIREMENTS
------------

- git 1.7 or later
- Bash shell


LICENSE
-------

Available under the GPL v2 license. See LICENSE.txt.

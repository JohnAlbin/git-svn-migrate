ABOUT git-svn-migrate
---------------------

Helper scripts to ease the migration of Subversion repositories to Git.

The basic steps to converting a list of Subversion repositories into Git
repositories is the following:

1. Retrieve a list of Subversion committers with:
   ./fetch-svn-author.sh  --url-file=[filename] > [output file for raw authors]

2. Edit the raw list of Subverions committers to provide full names and emails.

3. Convert the Subverion repositories into bare Git repositories with:
   ./git-svn-migrate.sh --url-file=[filename] --authors-file=[filename] [destination folder]


USAGE
-----

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

Example:

$ ./fetch-svn-author.sh my-repository-list.txt > authors-raw.txt

The above command will produce a list of unique authors for all of the
Subversion repositories listed in the my-repository-list.txt file. The contents
of authors-raw.txt 


AUTHENTICATION
--------------

Authenticating with each of the repositories is out-of-scope for these scripts.
You should ensure that all of the SVN repositories can be accessed
non-interactively (i.e. no password prompts) in order for these scripts to work.


LICENSE
-------

Available under the GPL v2 license. See LICENSE.txt.





@TODO
-----

      -A<filename>, --authors-file=<filename>
           Syntax is compatible with the file used by git cvsimport:

                       loginname = Joe User <user@example.com>

           If this option is specified and git svn encounters an SVN committer name that does not exist in the authors-file, git svn
           will abort operation. The user will then have to add the appropriate entry. Re-running the previous git svn command after
           the authors-file is modified should continue operation.

               config key: svn.authorsfile

       --authors-prog=<filename>
           If this option is specified, for each SVN committer name that does not exist in the authors file, the given file is executed
           with the committer name as the first argument. The program is expected to return a single line of the form "Name <email>",
           which will be treated as if included in the authors file.

       create-ignore
           Recursively finds the svn:ignore property on directories and creates matching .gitignore files. The resulting files are
           staged to be committed, but are not committed. Use -r/--revision to refer to a specific revision.


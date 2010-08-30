#!/bin/sh

# Copyright 2010 John Albin Wilkins.
# Available under the GPL v2 license. See LICENSE.txt.

script=`basename $0`;
usage=$(cat <<EOF_USAGE
USAGE: $script --url-file=<filename> --authors-file=<filename> [destination folder]
\n
\nFor more info, see: $script --help
EOF_USAGE
);

help=$(cat <<EOF_HELP
NAME
\n\t$script - Migrates Subversion repositories to Git
\n
\nSYNOPSIS
\n\t$script [options] [arguments]
\n
\nDESCRIPTION
\n\tThe $script utility migrates a list of Subversion
\n\trepositories to Git using the specified authors list. The
\n\turl-file and authors-file parameters are required. The
\n\tdestination folder is optional and can be specified as an
\n\targument or as a named parameter.
\n
\n\tThe following options are available:
\n
\n\t-u=<filename>, -u <filename>,
\n\t--url-file=<filename>, --url-file <filename>
\n\t\tSpecify the file containing the Subversion repository list.
\n
\n\t-a=<filename>, -a <filename>,
\n\t--authors-file=[filename], --authors-file [filename]
\n\t\tSpecify the file containing the authors transformation data.
\n
\n\t-d=<folder>, -d <folder,
\n\t--destination=<folder>, --destination <folder>
\n\t\tThe directory where the new Git repositories should be
\n\t\tsaved. Defaults to the current directory.
\n
\nBASIC EXAMPLES
\n\t# Use the long parameter names
\n\t$script --url-file=my-repository-list.txt --authors-file=authors-file.txt --destination=/var/git
\n
\n\t# Use short parameter names
\n\t$script -u my-repository-list.txt -a authors-file.txt /var/git
\n
\nSEE ALSO
\n\tfetch-svn-authors.sh
\n\tsvn-lookup-author.sh
EOF_HELP
);


# Set defaults for any optional parameters or arguments.
destination='.';

# Process parameters.
until [[ -z "$1" ]]; do
  # Strip off leading '--' or '-'.
  if [[ ${1:0:1} == '-' ]]; then
    if [[ ${1:0:2} == '--' ]]; then
      tmp=${1:2};
    else
      tmp=${1:1};
    fi
  else
    # Any argument given is assumed to be the destination folder.
    tmp="destination=$1";
  fi
  parameter=${tmp%%=*}; # Extract option's name.
  value=${tmp##*=};     # Extract option's value.
  # If the value is not specified inside the parameter, grab the next param.
  if [[ $value == $tmp ]]; then
    if [[ ${2:0:1} == '-' ]]; then
      # The next parameter is a new option, so unset the value.
      value='';
    else
      value=$2;
      shift;
    fi
  fi

  case $parameter in
    u )            url_file=$value;;
    url-file )     url_file=$value;;
    a )            authors_file=$value;;
    authors-file ) authors_file=$value;;
    d )            destination=$value;;
    destination )  destination=$value;;

    h )            echo $help | less >&2; exit;;
    help )         echo $help | less >&2; exit;;

    * )            echo "Unknown option: $1\n$usage" >&2; exit 1;;
  esac

  # Remove the processed parameter.
  shift
done

# Check for required parameters.
if [[ $url_file == '' || $authors_file == '' ]]; then
  echo $usage >&2;
  exit 1;
fi
# Check for valid files.
if [[ ! -f $url_file ]]; then
  echo "Specified URL file \"$url_file\" does not exist or is not a file." >&2;
  echo $usage >&2;
  exit 1;
fi
if [[ ! -f $authors_file ]]; then
  echo "Specified authors file \"$authors_file\" does not exist or is not a file." >&2;
  echo $usage >&2;
  exit 1;
fi


# Process each URL in the repository list.
tmp_destination="tmp-git-repo";
pwd=`pwd`;
mkdir -p $destination;
while read line
do
  # Check for 2-field format:  Name [tab] URL
  name=`echo $line | awk '{print $1}'`;
  url=`echo $line | awk '{print $2}'`;
  # Check for simple 1-field format:  URL
  if [[ $url == '' ]]; then
    url=$name;
    name=`basename $url`;
  fi
  # Process each Subversion URL.
  echo
  echo "Processing \"$name\" repository at $url..." >&2;
  rm -r $tmp_destination >&2 /dev/null;
  git svn clone $url --no-metadata -A $authors_file --authors-prog=./svn-lookup-author.sh --stdlayout --quiet $tmp_destination;
  cd $tmp_destination;
  # Create .gitignore file
  git svn show-ignore >> .gitignore;
  git add .gitignore;
  git commit --author="git-svn-migrate <nobody@example.org>" -m 'Convert svn:ignore properties to .gitignore.';
  # Remove unneeded git-svn config variables and internal files.
  git config --remove-section svn-remote.svn;
  git config --remove-section svn;
  rm -r .git/svn;
  cd $pwd;
  git clone --bare $tmp_destination $destination/$name.git;
  rm -r $tmp_destination;
  cd $destination/$name.git;
  git remote rm origin;
  cd $pwd;
done < $url_file

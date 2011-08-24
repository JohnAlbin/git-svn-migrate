#!/bin/bash

# Copyright 2010 John Albin Wilkins.
# Available under the GPL v2 license. See LICENSE.txt.

script=`basename $0`;
usage=$(cat <<EOF_USAGE
USAGE: $script --url-file=<filename> --destination=<filename>
\n
\nFor more info, see: $script --help
EOF_USAGE
);

help=$(cat <<EOF_HELP
NAME
\n\t$script - Retrieves Subversion usernames from a list of
\n\tURLs for use in a git-svn-migrate (or git-svn) conversion.
\n
\nSYNOPSIS
\n\t$script [options]
\n
\nDESCRIPTION
\n\tThe $script utility creates a list of Subversion committers
\n\tfrom a list of Subversion URLs from thto Git using the
\n\tspecified authors list. The url-file parameter is required.
\n\tIf the destination parameter is not specified the authors
\n\twill be displayed in standard output.
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
\n\t$script --url-file=my-repository-list.txt --destination=authors-file.txt
\n
\n\t# Use short parameter names and redirect standard output
\n\t$script -u my-repository-list.txt > authors-file.txt
\n
\nSEE ALSO
\n\tgit-svn-migrate.sh
EOF_HELP
);


# Set defaults for any optional parameters or arguments.
destination='';

# Process parameters.
until [[ -z "$1" ]]; do
  option=$1;
  # Strip off leading '--' or '-'.
  if [[ ${option:0:1} == '-' ]]; then
    if [[ ${option:0:2} == '--' ]]; then
      tmp=${option:2};
    else
      tmp=${option:1};
    fi
  else
    # Any argument given is assumed to be the destination folder.
    tmp="destination=$option";
  fi
  parameter=${tmp%%=*}; # Extract option's name.
  value=${tmp##*=};     # Extract option's value.
  case $parameter in
    # Some parameters don't require a value.
    #no-minimize-url ) ;;

    # If a value is expected, but not specified inside the parameter, grab the next param.
    * )
      if [[ $value == $tmp ]]; then
        if [[ ${2:0:1} == '-' ]]; then
          # The next parameter is a new option, so unset the value.
          value='';
        else
          value=$2;
          shift;
        fi
      fi
      ;;
  esac

  case $parameter in
    u )            url_file=$value;;
    url-file )     url_file=$value;;
    d )            destination=$value;;
    destination )  destination=$value;;

    h )            echo $help | less >&2; exit;;
    help )         echo $help | less >&2; exit;;

    * )            echo "Unknown option: $option\n$usage" >&2; exit 1;;
  esac

  # Remove the processed parameter.
  shift;
done

# Check for required parameters.
if [[ $url_file == '' ]]; then
  echo $usage >&2;
  exit 1;
fi
# Check for valid file.
if [[ ! -f $url_file ]]; then
  echo "Specified URL file \"$url_file\" does not exist or is not a file." >&2;
  echo $usage >&2;
  exit 1;
fi


# Process each URL in the repository list.
tmp_file="tmp-authors-transform.txt";
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
  # Process the log of each Subversion URL.
  echo "Processing \"$name\" repository at $url..." >&2;
  /bin/echo -n "  " >&2;
  svn log -q $url | awk -F '|' '/^r/ {sub("^ ", "", $2); sub(" $", "", $2); print $2" = "$2" <"$2">"}' | sort -u >> $tmp_file;
  echo "Done." >&2;
done < $url_file

# Process temp file one last time to show results.
if [[ $destination == '' ]]; then
  # Display on standard output.
  cat $tmp_file | sort -u;
else
  # Output to the specified destination file.
  cat $tmp_file | sort -u > $destination;
fi
unlink $tmp_file;

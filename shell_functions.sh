#! /bin/bash

switchphp ()
{
    if grep -qF 'CentOS Linux release 7' /etc/redhat-release; then
        printf "switchphp doesn't support Nexcess Cloud systems\n";
        return 1;
    fi
    iworxversion=$(rpm -qa --queryformat '%{VERSION}\n' interworx)
    if [[ ! $iworxversion =~ ^6 ]]; then
        pluginenabled=$(nodeworx -u -n -c Plugins -a listPlugins -o json | jq -r ".[] | select(.name == \"nexcess-php-scl\") | .status")
        if [ "$pluginenabled" != "true" ]; then
            printf "Nexcess-php-scl plugin not enabled!\n"
            return 1
        fi
    fi

    masterdomain=$(nodeworx -u -n -c Siteworx -a listAccounts -o json | jq -r ".[] | select(.uniqname == \"$1\") | .domain")

    if [[ $iworxversion =~ ^6 ]]; then

        validsclversions=$(find /opt/remi/*/root/usr/bin/php | grep -oP '(?<=php)[0-9][0-9]')

    else

        validsclversions=$(find /opt/nexcess/*/root/usr/bin/php | grep -oP '(?<=php)[0-9][0-9]')

    fi

    formattedvalidsclversions=$( printf "%s" "$validsclversions" | tr '\n' ' ')

    function isValidPhpVersion () {
        grep -q "^${1}$" <( printf "default\n"
        printf "%s" "$validsclversions" )
    }


    if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then

        printf "Usage: switchphp [USERNAME] [PHPVERSION]\n"
        printf "\n"
        printf "PHPVERSION must be one value from the set [ default %s]\n" "$formattedvalidsclversions"
        return 1

    elif [ -z "$1" ] || [ -z "$2" ]; then

        printf "switchphp requires two arguments or -h for help!\n"
        return 1

    elif ! id "$1" > /dev/null 2>&1; then

        printf "%s is not a valid user!\n" "$1"
        return 1

    elif ! isValidPhpVersion "$2"; then

        printf "%s is not a valid PHP version!\n" "$2"
        printf "Try one of [ default %s]\n" "$formattedvalidsclversions"
        return 1

    else

        username="$1"

        if [ "$2" = "default" ]; then
            if [[ $iworxversion =~ ^6 ]]; then

                printf "There is no default PHP version, you must choose a version.\n"

            else

                desiredphpversion="php"
                phpversion=$(/usr/bin/php -v | grep -oP '(?<=PHP )\d+\.\d+\.\d+')

            fi
        else

            if [[ $iworxversion =~ ^6 ]]; then

                desiredphpversion="${2}"
                phpversion=$(/opt/remi/php"${desiredphpversion}"/root/usr/bin/php -v | grep -oP '(?<=PHP )\d+\.\d+\.\d+')

            else

                desiredphpversion="php${2}u"
                phpversion=$(/opt/nexcess/"${desiredphpversion}"/root/usr/bin/php -v | grep -oP '(?<=PHP )\d+\.\d+\.\d+')

            fi
        fi
    fi

    if [[ $iworxversion =~ ^6 ]]; then

        phpswitchoutput=$(siteworx -u -n --login_domain "$masterdomain" -c Prefs -a phpOptions --default_php_version="/opt/remi/php${desiredphpversion}" 2>&1)

    else

        phpswitchoutput=$(siteworx -u -n --login_domain "$masterdomain" -c Nexphp -a setPhpVersion --php_version "$desiredphpversion" 2>&1)

    fi

    if [ ! -n "$phpswitchoutput" ]; then

        # it worked
        printf "User %s switched to PHP version: %s\n" "$username" "$phpversion"
        return 0

    elif ( echo "$phpswitchoutput" | grep -qE '^php_version : ".*" This is not a valid option' ) ; then

        # it didn't work and we know why
        printf "PHP switch failed. \"%s\" is not enabled as an available PHP version for this siteworx account.\n" "$desiredphpversion"

        return 1
    else

        # it didn't work and we don't know why
        printf "PHP switch failed. Output from siteworx regarding this failure below:\n%s\n" "$phpswitchoutput"
        return 1

    fi
}

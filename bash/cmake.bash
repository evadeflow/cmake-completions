# bash completion for cmake(1)
#
# To use this file, source it directly from a terminal, or add:
#
#   source cmake.bash
#
# to your .bashrc...

_cmake()
{
    local cur prev words cword split=false
    _init_completion -n := || return

    # Workaround for options like -DCMAKE_BUILD_TYPE=Release
    local prefix=
    if [[ $cur == -D* ]]; then
        prev=-D
        prefix=-D
        cur="${cur#-D}"
    elif [[ $cur == -U* ]]; then
        prev=-U
        prefix=-U
        cur="${cur#-U}"
    fi

    case "$prev" in
        -D)
            if [[ $cur == *=* ]]; then
            # complete values for variables
                local var type value
                var="${cur%%[:=]*}"
                value="${cur#*=}"

                # CUSTOM:
                # ===VALUES===
                # Any variables whose *values* you want to complete when no
                # CMakeCache.txt file is present should go here. (See the
                # '===VARIABLES===' section for the code that completes the
                # variable *names*.)
                case "$var" in
                    BUILD_TESTS* | \
                    ENABLE_AUDIT* | \
                    ENABLE_ENGINEERING_BUILD* | \
                    INCLUDE_TESTS_IN_ALL*)
                        COMPREPLY=( $( compgen -W 'ON OFF' -- \
                            "$value" ) )
                        return
                        ;;

                    CMAKE_BUILD_TYPE*)
                        COMPREPLY=( $(compgen -W 'Debug Release RelWithDebInfo
                            MinSizeRel' -- "$value") )
                        return
                        ;;
                    
                    GUI_OPTION*) # CUSTOM
                        COMPREPLY=( $(compgen -W 'sqlite xfiles' -- "$value") )
                        return
                        ;;

                    SOUND_DRIVER*) # CUSTOM
                        COMPREPLY=( $(compgen -W 'alsa oss none' -- "$value") )
                        return
                        ;;
                    TEST_RUNNER*) # CUSTOM
                        COMPREPLY=( $(compgen -W 'ErrorPrinter
                            XUnitPrinter' -- "$value" ) )
                        return
                        ;;
                    WARNING_HUNTING*) # CUSTOM
                        COMPREPLY=( $(compgen -W '0 1 2 3 4' -- "$value" ) )
                        return
                        ;;
                esac

                if [[ $cur == *:* ]]; then
                    type="${cur#*:}"
                    type="${type%%=*}"
                else # get type from cache if it's not set explicitly
                    type=$( cmake -LA -N 2>/dev/null | grep "$var:" \
                        2>/dev/null )
                    type="${type#*:}"
                    type="${type%%=*}"
                fi
                case "$type" in
                    FILEPATH)
                        cur="$value"
                        _filedir
                        return
                        ;;
                    PATH)
                        cur="$value"
                        _filedir -d
                        return
                        ;;
                    BOOL)
                        COMPREPLY=( $( compgen -W 'ON OFF TRUE FALSE' -- \
                            "$value" ) )
                        return
                        ;;
                    STRING|INTERNAL)
                        # no completion available
                        return
                        ;;
                esac
            elif [[ $cur == *:* ]]; then
            # complete types
                local type="${cur#*:}"
                COMPREPLY=( $( compgen -W 'FILEPATH PATH STRING BOOL INTERNAL'\
                    -S = -- "$type" ) )
                compopt -o nospace
            else
            # complete variable names
                CACHE_VARS=( $(cmake -LA -N | tail -n +2 | cut -f1 -d:) )

                # CUSTOM:
                # ===VARIABLES===
                # Any '-D' variables whose *names* you want to complete when
                # there is no CMakeCache.txt file present should go here.
                CUSTOM_VARS=( \
                    "BUILD_TESTS" \
                    "CMAKE_BUILD_TYPE" \
                    "ENABLE_AUDIT" \
                    "ENABLE_ENGINEERING_BUILD" \
                    "GUI_OPTION" \
                    "INCLUDE_TESTS_IN_ALL" \
                    "SOUND_DRIVER" \
                    "TEST_RUNNER" \
                    "WARNING_HUNTING" \
                )
                ALL_VARS=("${CUSTOM_VARS[@]}" "${CACHE_VARS[@]}")
                COMPREPLY=( $(compgen -W '${ALL_VARS[@]}' -P "$prefix" -- "$cur") )
                compopt -o nospace
            fi
            return
            ;;
        -U)
            COMPREPLY=( $( compgen -W '$( cmake -LA -N | tail -n +2 |
                cut -f1 -d: )' -P "$prefix" -- "$cur" ) )
            return
            ;;
    esac

    _split_longopt && split=true

    case "$prev" in
        -C|-P|--graphviz|--system-information)
            _filedir
            return
            ;;
        --build)
            _filedir -d
            return
            ;;
        -E)
            COMPREPLY=( $( compgen -W "$( cmake -E help |& sed -n \
                '/^  /{s|^  \([^ ]\{1,\}\) .*$|\1|;p}' 2>/dev/null )" \
                -- "$cur" ) )
            return
            ;;
        -G)
            local IFS=$'\n'
            local quoted
            printf -v quoted %q "$cur"
            COMPREPLY=( $( compgen -W '$( cmake --help 2>/dev/null | sed -n \
                -e "1,/^Generators/d" \
                -e "/^  *[^ =]/{s|^ *\([^=]*[^ =]\).*$|\1|;s| |\\\\ |g;p}" \
                2>/dev/null )' -- "$quoted" ) )
            return
            ;;
        --help-command)
            COMPREPLY=( $( compgen -W '$( cmake --help-command-list 2>/dev/null|
                grep -v "^cmake version " )' -- "$cur" ) )
            return
            ;;
        --help-module)
            COMPREPLY=( $( compgen -W '$( cmake --help-module-list 2>/dev/null|
                grep -v "^cmake version " )' -- "$cur" ) )
            return
            ;;
         --help-policy)
            COMPREPLY=( $( compgen -W '$( cmake --help-policies 2>/dev/null |
                grep "^  CMP" 2>/dev/null )' -- "$cur" ) )
            return
            ;;
         --help-property)
            COMPREPLY=( $( compgen -W '$( cmake --help-property-list \
                2>/dev/null | grep -v "^cmake version " )' -- "$cur" ) )
            return
            ;;
         --help-variable)
            COMPREPLY=( $( compgen -W '$( cmake --help-variable-list \
                2>/dev/null | grep -v "^cmake version " )' -- "$cur" ) )
            return
            ;;
    esac

    $split && return

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $(compgen -W '$( _parse_help "$1" --help )' -- ${cur}) )
        [[ $COMPREPLY == *= ]] && compopt -o nospace
        [[ $COMPREPLY ]] && return
    fi

    _filedir
} &&
complete -F _cmake cmake

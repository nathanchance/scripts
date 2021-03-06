#!/usr/bin/env fish
# SPDX-License-Identifier: MIT
# Copyright (C) 2021 Nathan Chancellor

function ssh_agent -d "Launch an ssh agent only if it has not already been launched"
    status is-interactive; or return 0

    set ssh_key $HOME/.ssh/id_ed25519
    if not test -r "$ssh_key"
        return
    end

    set ssh_agent_file $HOME/.ssh/.ssh-agent.fish
    ssh-add -l &>/dev/null
    if test $status -eq 2
        if test -r $ssh_agent_file
            cat $ssh_agent_file | source >/dev/null
        end

        ssh-add -l &>/dev/null
        if test $status -eq 2
            begin
                umask 066
                ssh-agent -c >$ssh_agent_file
            end
            cat $ssh_agent_file | source >/dev/null
            ssh-add $ssh_key
        end
    end
end

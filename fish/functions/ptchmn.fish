#!/usr/bin/env fish
# SPDX-License-Identifier: MIT
# Copyright (C) 2021 Nathan Chancellor

function ptchmn -d "Quilt-like patch management function for Linux"
    in_kernel_tree; or return

    set repo (basename $PWD)
    set out $GITHUB_FOLDER/patches/$repo/(git cb)
    if not test -d $out
        print_error "$out does not exist!"
        return 1
    end

    switch $argv[1]
        case -a --apply
            git am $out/*

        case -s --sync
            switch $repo
                case linux-next linux linux-stable-5.'*'
                case '*'
                    print_error "$repo not supported by ptchmn!"
                    return 1
            end

            set mfc (git mfc)
            if test -z "$mfc"
                print_error "My first commit does not exist?"
                return 1
            end

            rm $out/*
            git fp -o $out --base=$mfc^ $mfc^..HEAD
            git -C $out aa
            git -C $out c -m "patches: $repo: "(git cb)": sync as of"(git sh -s --format=%h)
            git -C $out push
    end
end

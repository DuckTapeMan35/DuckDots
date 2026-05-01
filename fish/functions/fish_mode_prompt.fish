# Display the current binding mode... if it's vi or vi-like.
#
# To always show the binding mode (regardless of current bindings):
#     set -g theme_display_vi yes
#
# To never show:
#     set -g theme_display_vi no

function fish_mode_prompt -d 'bobthefish-optimized fish mode indicator'
    [ "$theme_display_vi" != 'no' ]
    or return

    [ "$fish_key_bindings" = 'fish_vi_key_bindings' \
        -o "$fish_key_bindings" = 'hybrid_bindings' \
        -o "$fish_key_bindings" = 'fish_hybrid_key_bindings' \
        -o "$theme_display_vi" = 'yes' ]
    or return

    __bobthefish_colors $theme_color_scheme

    type -q bobthefish_colors
    and bobthefish_colors

    set_color normal # clear out anything bold or underline...

    switch $fish_bind_mode
        case default
            set_color -b $color_vi_mode_default
            echo -n ' N '
            set_color -b $color_vi_mode_default_reverse
            echo ""
        case insert
            set_color -b $color_vi_mode_insert
            echo -n ' I '
            set_color -b $color_vi_mode_insert_reverse
            echo ""
        case replace replace_one replace-one
            set_color -b $color_vi_mode_insert
            echo -n ' R '
            set_color -b $color_vi_mode_insert_reverse
            echo ""
        case visual
            set_color -b $color_vi_mode_visual
            echo -n ' V '
            set_color -b $color_vi_mode_visual_reverse
            echo ""
    end

    set_color normal
end

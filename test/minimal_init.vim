set rtp+=.
if $PLENARY != "" && isdirectory($PLENARY)
  set rtp+=$PLENARY
endif
runtime! plugin/plenary.vim

" Add test/ directory to Lua's package.path
lua << EOF
package.path = package.path .. ';./test/?.lua;./test/?/init.lua'
EOF


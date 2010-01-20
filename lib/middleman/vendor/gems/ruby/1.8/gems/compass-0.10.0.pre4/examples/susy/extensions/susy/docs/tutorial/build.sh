#!/bin/bash

tut_dir=`dirname ${0}`
cd "${tut_dir}"
tut_dir=`pwd`

if [ ! -d "_build" ]; then
    mkdir "_build"
fi

cp -pR code/* _build/
cd _build

# create activate and deactivate scripts
cat > activate <<EOF
#!/bin/bash 

cd "${tut_dir}/_build"
pushd ../../../lib > /dev/null
libdir=\`pwd\`
popd > /dev/null

export OLD_RUBYLIB=\${RUBYLIB}
export RUBYLIB=\${libdir}
EOF

cat > deactivate <<EOF
#!/bin/bash

export RUBYLIB=\${OLD_RUBYLIB}
export OLD_RUBYLIB=
EOF

# activate so we can run compass later
. activate

# create the site index.html and place it in _common
cat _tools/head.tpl.html \
    | sed 's/{{ STYLE_PATH }}//; s/{{ BODY_CLASS }}/home/; s/{{ TITLE }}/A Grid Plugin for Compass/;' \
    > _tools/home_head.html
cat _tools/foot.tpl.html \
    | sed 's/{{ STYLE_PATH }}//;' \
    > _tools/home_foot.html
cat _tools/home_head.html _tools/home_content.html _tools/home_foot.html > _common/index.html

# copy the tutorial figures into site/
if [ ! -d "site/tutorial" ]; then
    mkdir site/tutorial
fi
cp -pR ../figures site/tutorial/

# create the tutorial index.html
perl _tools/Markdown.pl --html4tags ../index.mkdn > _tools/tutorial_content.html
cat _tools/head.tpl.html \
    | sed 's/{{ STYLE_PATH }}/..\//; s/{{ BODY_CLASS }}/tutorial/; s/{{ TITLE }}/A Tutorial/;' \
    > _tools/tutorial_head.html
cat _tools/foot.tpl.html \
    | sed 's/{{ STYLE_PATH }}/..\//;' \
    > _tools/tutorial_foot.html
cat _tools/tutorial_head.html _tools/tutorial_content.html  _tools/tutorial_foot.html > site/tutorial/index.html

# remove _tools
rm -r _tools/

# copy files in _common into each stage; also create diff.sh and use.sh
for d in 01_target 02_container 03_structure site; do
    cp -pR _common/* "${d}/"
    pushd "${d}" > /dev/null
    compass > /dev/null
    popd > /dev/null
    cat > "${d}/diff.sh" <<EOF
#!/bin/bash

pushd \`dirname \${0}\` > /dev/null
name=\`basename \\\`pwd\\\`\`
diff -r ${tut_dir}/code/\${name}/src/ src/
popd > /dev/null
EOF
    chmod 755 "${d}/diff.sh"
    cat > "${d}/use.sh" <<EOF
#!/bin/bash

pushd \`dirname \${0}\` > /dev/null
name=\`basename \\\`pwd\\\`\`
dest="${tut_dir}/code/\${name}/\${1}"
if [ ! -f "\${dest}" ]; then
    echo "File \${dest} does not exist; does this file belong in _common?"
    exit 1
fi
cp "\${1}" "\${dest}"
popd > /dev/null
EOF
    chmod 755 "${d}/use.sh"
done

# got everything out of common, remove it
rm -r _common

# move all stages into site/tutorial/
for d in 01_target 02_container 03_structure; do
    cp -pR "${d}" site/tutorial/
    rm -r "${d}"
done

# create install script
cat > install.sh <<EOF
#!/bin/bash

if [ -z "\${1}" ]; then
    echo "Please provide a destination directory to install Susy site into."
    exit 1
fi

if [ -e "\${1}" ]; then
    read -n 1 -p "Destination \${1} already exists, remove it (y/n)?" yesno
    echo
    echo
    if [ \$yesno != "y" ]; then
        echo "Aborting."
        exit 1
    fi
    rm -r \${1}
fi


echo "Installing Susy site to \${1}."

pushd \`dirname \${0}\` > /dev/null
base=\`pwd\`
popd > /dev/null
cp -pR "\${base}/site/" "\${1}" || exit 1

find "\${1}" -name '*.sh' -exec rm {} \;
echo "Installed."
EOF
chmod 755 install.sh

# if we got an argument, go ahead and install there
if [ ! -z "${1}" ]; then
    ./install.sh "${1}"
fi

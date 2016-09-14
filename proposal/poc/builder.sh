#!/bin/bash

# Preprocessor to setup the asciibinder repository

# To Do:
# * This should read _distro_map.yml and something like _git_map.yml to dynamically generate itself
# * Cleanup the publishing branches when we start
# * Write a reset script
# * This needs to link to the proper translation of Common_Content

# This assume a ~/.config/zanata.ini with user credentials

zanataurl=https://fedora.zanata.org
zanataproject=docs-sandbox

LANGS="ja
fr"

BRANCHES="master-adoc
f24-adoc
f23-adoc"

BOOKS="bex-install-guide
bex-virt-getting-started-guide"

ja_BOOKS="bex-install-guide
bex-virt-getting-started-guide"

fr_BOOKS="bex-install-guide"

DATE=`date`

# Set up base version branches
for branch in $BRANCHES; do
    git checkout -b $branch
done

# Set up Common Content
for branch in $BRANCHES; do
    git checkout $branch
    git subtree add --prefix _Common_Content https://pagure.io/docs-common-content.git master-adoc --squash
done

# First build out en-US
for lang in "en-US"; do
    for branch in $BRANCHES; do
        langbranch=$branch-$lang

        git checkout $branch
        git checkout -b $langbranch

        # Get books
        for book in $BOOKS; do
            # Book Source into _git
            git subtree add --prefix _git/$book https://pagure.io/$book.git $branch --squash
        done
    
        # Preprocess the books (this ordering prevents having to have a commit in every pass)
        for book in $BOOKS; do
            # Link in the baselang to the root directory
            dir=`echo $book | sed -e 's/bex-//'` # Temporary because using my repos
            ln -s _git/$book/en-US $dir
    
            # Update the _topic_map.yml
            cp _git/$book/_topic_map.yml temp_topic_map.yml
            sed -i -e "s/^Dir: en-US/Dir: $dir/" temp_topic_map.yml
            cat temp_topic_map.yml >> _topic_map.yml
            rm temp_topic_map.yml

            # Update include links in the books (find -L follows symlinks)
            find -L $dir -iname *.adoc  | xargs -I FILE sed -i -e "s/include::en-US/include::$dir/  " FILE

            # Commit it all baby
            git add .
            git commit -m "Build on $DATE"
        done
    done
done

# Now try the languages
for lang in $LANGS; do
    for branch in $BRANCHES; do
        langbranch=$branch-$lang
        langbooksvar=$lang\_BOOKS
        langbooks=${!langbooksvar}

        git checkout $branch
        git checkout -b $langbranch

        # Get books
        for book in $langbooks; do
            # Book Source into _git
            git subtree add --prefix _git/$book https://pagure.io/$book.git $branch --squash
        done
    
        # Preprocess the books (this ordering prevents having to have a commit in every pass)
        for book in $langbooks; do
            # Link in the baselang to the root directory
            dir=`echo $book | sed -e 's/bex-//'` # Temporary because using my repos
            ln -s _git/$book/en-US $dir
    
            # Update the _topic_map.yml
            cp _git/$book/_topic_map.yml temp_topic_map.yml
            sed -i -e "s/^Dir: en-US/Dir: $dir/" temp_topic_map.yml
            cat temp_topic_map.yml >> _topic_map.yml
            rm temp_topic_map.yml

            # Update include links in the books (find -L follows symlinks)
            find -L $dir -iname *.adoc  | xargs -I FILE sed -i -e "s/include::en-US/include::$dir/  " FILE

            # Pull the .pot files
            zanata pull --url $zanataurl --project-id $zanataproject --project-version $dir --lang $lang --transdir pot/ --project-type podir

            # Apply the translations
            # Right now this accepts all percentages of translation
            # -L makes find follow symlinks

            for file in $( find -L $dir -name "*.adoc" ); do
                basename=`basename -s .adoc $file`
                po4a-translate -f asciidoc -m $file -l $file -p pot/$lang/$basename.po -M UTF-8 -k 0
            done

            # Commit it all baby
            date=`date`
            git add .
            git commit -m "Build on $date"
        done
    done
done

git checkout master-adoc

# Build out _distro_map.yml
cp _distro_map.yml model_distro_map.yml
for lang in $LANGS; do
    # Entries in _distro_map.yml
    cp model_distro_map.yml temp_distro_map.yml
    sed -i -e "s/en-US/$lang/g" temp_distro_map.yml
    sed -i -e "s/^--*$//" temp_distro_map.yml
    cat temp_distro_map.yml >> _distro_map.yml
    rm temp_distro_map.yml

    # index page
    cp index-en-US.html index-$lang.html
done
rm model_distro_map.yml

# Build commit
git add .
git commit -m "Build on $DATE"

asciibinder package
cp index-master.html _package/index.html

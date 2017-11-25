BASE_PATH=`dirname $0`

DEFAULT_TEMPLATE=posts.html
TARGET_DIR=$BASE_PATH/target
BASE_FILE=index.html

create_target_dir_if_necessary() {
    if [ ! -d "$BASE_PATH/target" ]; then
        echo "Creating target directory"
        mkdir "$TARGET_DIR"
    fi
}

clean() {
    if [ -d "$TARGET_DIR" ]; then
        echo "Removing target directory"
        rm -r "$TARGET_DIR"
    fi
}

create_target_files() {
    for file in $BASE_PATH/*.html; do
        create_target_file $file
    done
}

create_target_file() {
    TEMPLATE_FILE=$1
    if [[ $1 == *$BASE_FILE ]]; then
        TEMPLATE_FILE=$DEFAULT_TEMPLATE
    fi
    TITLE=`sed -rn '1,1s/.*title=(.+)-->/\1/p' $BASE_PATH/$TEMPLATE_FILE`
    TEMPLATE_CONTENT=`sed -n '1,1!p' $BASE_PATH/$TEMPLATE_FILE | tr -d '\n'`
    sed -r "s/\{\{title\}\}/$TITLE/ ; s#\{\{content\}\}#$TEMPLATE_CONTENT#" $BASE_PATH/index.html > $TARGET_DIR/$1
}

copy_resources() {
    for style in $BASE_PATH/*.css; do
        cp $style $TARGET_DIR
    done
    if [ -d "$BASE_PATH/images" ]; then
        cp -r $BASE_PATH/images $TARGET_DIR/images
    fi

    if [ -d "$BASE_PATH/fonts" ]; then
        cp -r $BASE_PATH/fonts $TARGET_DIR/fonts
    fi
}

all() {
    clean
    create_target_dir_if_necessary
    create_target_files
    copy_resources
}

on_change() {
    if [[ $1 =~ .*\.(html|css)$ ]]; then
        echo "File $1 changed; rebuilding..."
        all
    else
        echo "Ignoring modified file $1"
    fi
}

if [[ $1 == "--watch" ]]; then
    all
    echo "Waiting for changes..."
    while RES=`inotifywait --quiet --event modify --format %f $BASE_PATH`; do
        on_change $RES
        echo "Waiting for changes..."
    done
else
    all
fi

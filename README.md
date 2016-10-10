
# Develop techs

Framework based on `Angular.JS.`

Pages are written with `Jade`

Stylesheets are written with `SASS`

Page scripts are written with `CoffeeScript`

And all compilations are completed by the automatic deploying tool `gulp`

All source codes are in the `src` directory. 
And the compiled files are in the `www` directory (which is not under the version control). 
Site's root directory is `www`.

# Requirements

1. npm
2. bower: `npm install -g bower`

# Prepare

```
npm install
bower install
```

# start

`gulp`

# More detail develop instructions

## Jade

All `jade` files should be placed in `src/pages` directory. 
In the root of `src` jade directory, 
 there should be only one jade file `index.jade`. 
`index.jade` is the entry of the app. 
Other jade files are recommended to be placed in organized directories.

Gulp will compile each `jade` file into a `html` file,
 without changing the directory structure.
And then put them into the `www/pages` directory.

For example, you have such `src` structure:

```
src
  - ...
  - pages
    - login
      - login.jade
    - hall
      - hall.jade
      - personal_info
        - info.jade
        - rank.jade
  - index.jade
```

After gulp, you'll get such `www` structure:

```
www
  + vendor (the static files)
  - pages
    - login
      - login.html
    - hall
      - hall.html
      - personal_info
        - info.html
        - rank.html
  - index.html
```

## CoffeeScript

All `coffee` files should be placed in `src/scripts` directory.
I orgnize script files into the following categories:

1. `src/scripts/no-ng/`: The native JavaScripts that are not related to Angular
2. `src/scripts/app.coffee`: Angular entry file 
3. `src/scripts/global/`: Angular global scripts (configs, etc.)
4. `src/scripts/factories/`: Angular global factories
5. `src/scripts/directories/`: Angular global directives
6. `src/scripts/modules/`: Angular sub-modules, organized according to our site-map

Gulp will concat all the `coffee` files in the above order,
 there are no order in each categories.
And compile them into one JavaScript file `script.js`.
And then put it into `www/vendor/scripts/` directory.

## SASS

All `scss` files should be placed in `src/stylesheets` directory.
Organize the files as you like.
The `src/stylesheets/style.scss` is the main `scss` file,
 and other files are imported in this file.

Gulp will only compile `src/stylesheets/style.scss`,
 so you must import the required files into this file.
Gulp compiles the `style.scss` file into `style.css`, 
 and put it into `www/vendor/stylesheets` directory.
 
## Images
 
All image files should be placed in `src/images` directory.
Gulp will simply copy the whole directory to the `www/vendor/images`
 directory.
  
## FE Dependencies

jQuery, Angular and Bootstrap are the main dependencies in this project.
Gulp will simply copy the released minified `.min.css` files or `.min.js`
 files into `www/vendor/stylesheets` and `www/vendor/scripts/` directories.


## Other Notations

### Relative link URLs

About the links in the files: 
be aware that the link URLs in `jade`, `scss` and `coffee` files won't
be modified when being compiled. 
You have to consider the resulted `www` directory structure
 instead of the `src` directory stucture.

For example:

In any `jade` or `coffee` file, if you want to refer to an image file stored in
 `images` directory, you should write like this

`<img src="vendor/images/icons/icon-example.png" />`

As the `index.jade` file will be compiled as `www/index.html` 
 and other `jade`/`coffee` files will be loaded into `www/index.html` asynchronously.

In any `scss` file, if you want to specify an image url, 
 you should write like this:

`background-image: url(../images/icons/icon-example.png)`

As all the `scss` files will be compiled as `www/vendor/stylesheets/style.css`




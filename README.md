<p align="center">
	<img src="https://raw.githubusercontent.com/Sephiroth87/Crayons/master/Images/logo.png" alt="Logo" />
	<a href="https://gitter.im/Sephiroth87/Crayons?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge"><img src="https://badges.gitter.im/Join%20Chat.svg" alt="Join the chat at https://gitter.im/Sephiroth87/Crayons" /></a>
</p>

**Crayons** is an Xcode7 plugin with various features that improve working with colors in your projects

##Code palettes (iOS only)

<p align="center">
	<img src="https://raw.githubusercontent.com/Sephiroth87/Crayons/master/Images/CodePalettes.png" alt="CodePalettes" />
</p>

You can share palettes of colors from your source files, and use them directly in Interface Builder, without having to manually recreate them in the Color Picker.
And if you decide to change a color, you just need to change it's implementation.
Colors are generated dynamically, so you can use any method or calculation you need.
Because of that, project has to built to get updated colors, so it might take a while before they are updated in IB after a code change.

####Usage
Define a palette by adding the class method 
 
 ```
 	+ (NSString *)paletteName
	class func paletteName() -> String 
```

to any class (Class has to derive from NSObject at some level, so no pure Swift classes at the moment).
To define a color, add a class method or variable with any name that returns UIColor, for example

 ```
 	+ (UIColor *)colorName
	class func colorName() -> UIColor
	class var colorName: UIColor
```

Only methods with no parameters are supported at the moment, and only UIColors in the RGB and White color space (so no `colorWithPatternImage:`)

You can then create a category/extension of you palette class, to create a separate palette with the same name plus the category name (look at `GooglePalette` and `GooglePalette+Accents` in the example project) 

`UIColor` categories (like [Chameleon](https://github.com/ViccAlexander/Chameleon) will also generate palettes automatically.

Look at the example project for more infos.

##Upcoming features
* Colors validation (show IB warnings if using colors not defined in any palette)
* OSX support?
* More ways to define palettes/colors
* Show status of colors generations / indexing
* Any feature you think could be useful? Contact me ([@Sephiroth87](https://twitter.com/Sephiroth87))

##Installation
- Clone and build the project
- Use [Alcatraz](https://github.com/supermarin/Alcatraz)

Either way, restart Xcode to make it load

##Release notes
###1.3
- Add support for Swift class variables

###1.2
- Xcode 7.3 support
- Improved internal logic + bugfixes

###1.1
- You can now use categories/extensions for secondary palettes, and automatic UIColor palettes

###1.0
- Initial Release
- Code palettes for iOS

##License
Copyright (c) 2015. [Fabio Ritrovato](https://twitter.com/Sephiroth87)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Menu Page
![demo](https://github.com/fanwu8184/MenuPage/blob/master/Demos/demo.gif)
![demo1](https://github.com/fanwu8184/MenuPage/blob/master/Demos/demo1.gif)

Menu Page is an easy to use and flexible Menu View for iOS development. What you need to take care are the your menu views and your page views. Menu Page will handle the rest of the logic and functions.
- Swipe Between Pages
- Change settings Anytime
- Flexible
- Easy To Use

### Installation
Just need to download the MenuPage and SupportFiles folders into your project.

### How to use
##### Create Your Menu Views
```sh
let imageView: UIImageView = {
    let iv = UIImageView()
    iv.image = UIImage(named: "calendar")
    return iv
}()
        
let button: UIButton = {
    let b = UIButton()
    b.setImage(UIImage(named: "calendar"), for: .normal)
    b.setTitle("Button", for: .normal)
    return b
}()
```

##### Create Your Page Views
```sh
let pageView: UIView = {
    let view = UIView()
    view.backgroundColor = .red
    return view
}()
        
let pageView2: UIView = {
    let view = UIView()
    view.backgroundColor = .yellow
    return view
}()
        
let pageView3: UIView = {
    let view = UIView()
    view.backgroundColor = .blue
    return view
}()
        
let pageView4: UIView = {
    let view = UIView()
    view.backgroundColor = .green
    return view
}()
```

##### Create MenuPage Instances Via It's Model
You don't have to set menuView parameter. It's default value is a label view
```sh
let aaa = MenuPage(title: "AAA", pageView: pageView)
let bbb = MenuPage(title: "BBB", pageView: pageView2)
let ccc = MenuPage(title: "CCC", menuView: button, pageView: pageView3)
let ddd = MenuPage(title: "DDD", menuView: imageView, pageView: pageView4)
```

##### Create Instance of MenuPageView
```sh
let menuPage = MenuPageView()
menuPage.menuPages = [aaa, bbb, ccc, ddd]
```
or
```sh
let menuPage =  MenuPageView([aaa, bbb, ccc, ddd])
```

##### Setup MenuPageView
```sh
override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(menuPage)
    menuPage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
    menuPage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    menuPage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
    menuPage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
}
```
And done, That is it!

### Features
#### Update Your MenuPageView After Setup
![demo2](https://github.com/fanwu8184/MenuPage/blob/master/Demos/demo2.gif)

See the example code below
```sh
@objc func change(_ sender: UIBarButtonItem) {
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "calendar")
        return iv
    }()
        
    let pageView5: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
        
    let pageView6: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }()
        
        let eee = MenuPage(title: "AAA", pageView: pageView5)
        let fff = MenuPage(title: "FFF", menuView: imageView, pageView: pageView6)
        menuPage.menuPages = [eee, fff]
}
```

#### Set the Menu Bar Position
![demo3](https://github.com/fanwu8184/MenuPage/blob/master/Demos/demo3.gif)

See the example code below
```sh
func changeMenuBarPosition() {
    menuPage.isMenuBarAtTop = !menuPage.isMenuBarAtTop
}
```

#### Set The Columns Number for Menu On Screen, default is 5
![demo4](https://github.com/fanwu8184/MenuPage/blob/master/Demos/demo4.gif)

See the example code below
```sh
menuPage.columnsOfMenuOnScreen = 3
```

#### You Can Swipe Out And Swipe Back The Menu
![demo5](https://github.com/fanwu8184/MenuPage/blob/master/Demos/demo5.gif)

You need to set isSwipingOutModeOn to true first.
```sh
menuPage.isSwipingOutModeOn = true
```

#### Use CustomMenuItem Protocol To Customize Your Selected Or Unselected Menu Item's Behavior
See the example code below
```sh
class CustomMenuView: BasicView, CustomMenuItem {
    
    var isSelected: Bool = false {
        didSet {
            backgroundColor = isSelected ? .black : .orange
        }
    }
    
    override func setupViews() {
        super.setupViews()
    }
}

let customMenuView = CustomMenuView()
let example = MenuPage(title: "example", menuView: customMenuView, pageView: UIView())
```

#### The Other Settings
**Change the menu bar height, default is 50**
```sh
menuPage.menuBarHeight = 100
```
**Change the menu bar background color, default is UIcolor.clear**
```sh
menuPage.menuBarBackgroundColor = .orange
```
**Change the horizontal menu bar color, default is UIcolor.lightGray**
```sh
menuPage.horizontalMenuBarColor = .blue
```
**Change selected menu color, default is UIcolor.red**
```sh
menuPage.selectedMenuColor = .black
```
**Change not selected menu color, default is UIcolor.blue**
```sh
menuPage.notSelectedMenuColor = .yellow
```
**Set up a closure for currentIndexDidChange so that you can track the menu index change**
```sh
menuPage.currentIndexDidChange = { index in print(menuPage.menuPages[index].title) }

Tip: set this up before you set menuPage.menuPages will let you be able to track the initial value change
```
**Disable pages view bounce**
```sh
menuPage.setPagesBounce(false)
```
**Change the menu expand indicator color**
```sh
menuPage.menuBarExpandIndicatorColor = .red
```
**Change the horizontal menu bar's height**
```sh
menuPage.heightOfHorizontalBarInMenuBar = 0
```
**Change the padding between horizontal menu bar and menu bar items**
```sh
menuPage.paddingBetweenHorizontalBarAndMenuBarItem = 0
```

License
----

MIT

**Free Software, Hell Yeah!**

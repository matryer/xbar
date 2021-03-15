xbar (the BitBar reboot) has shipped, and you might want to upgrade your BitBar plugin.

Your plugin will run in xbar without any changes. However, there are a few tweaks you should make and one or two shiny new features to look at.

# What's new in xbar?

1. Unlock new features by upgrading your metadata - change `<bitbar.*>` tags to `<xbar.*>`
1. Use the `shell` parameter instead of `bash`
1. There is now no limit to the number of `paramN` parameters you can use
1. Use variables (new feature) instead of asking users to edit your scripts
1. Add keyboard shortcuts (new feature) to make your plugins even easier to use

## Variables for configuration

Variables are defined in your plugin's metadata. The xbar UI lets users configure the values without editing your script.

* To learn more, read about the [New Variables feature in xbar](/docs/2021/03/14/new-variables-feature-in-xbar.html)

## Keyboard shortcuts

xbar lets you specify keyboard shortcuts for your menu items.

Use the `key` parameter:

```
Let's go | key=shift+g | href=https://xbarapp.com/
```

You can specify a range of modifiers and special keys, for a full list check out the [Parameters documentation](https://github.com/matryer/xbar#parameters).

# Please try xbar, and report any issues

xbar is still brand new, so please help us reach a full release by reporting any issues you find.

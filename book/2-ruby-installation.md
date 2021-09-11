# Ruby Installation

Before going further, lets install `ruby` in our system. I will be using the Linux Ubuntu operating system in this book, therefore most of the installation instructions presented here are for Ubuntu. However, I have also provided links for setup instructions for windows 10 and macOS operating systems.

We are going to install Ruby using the [asdf](https://asdf-vm.com) version manager. `asdf` is an extendable version manager with support for Ruby, Node.js, Elixir, Erlang & more. It manages multiple language runtime versions on a per-project basis.

As a Rails developer, you might find yourself working on projects that use different versions of ruby (e.g Ruby 2.7 and Ruby 3.0). In that case, you will need a version manager (like `asdf` or `rbenv`) to manage and install the different versions of ruby in your system.

## Installing `asdf` in Ubuntu 18.04 or later

Open your terminal and run the following commands

```bash
$ git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1

$ echo -e '\n. $HOME/.asdf/asdf.sh' > .bashrc

$ echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
```

Restart your terminal and check if `asdf` installed correctly

```
$ asdf --version
```

The output should be `v0.8.1`

## Installing `asdf` in MacOS

You can install `asdf` using Homebrew in your terminal

```bash
$ brew install asdf
```

Add asdf to the .zshrc file

```
$ echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> ~/.zshrc
```

Close and re-open the terminal window for the changes to the `~/.zshrc` file to be recognized

Check if asdf installed correctly:

```bash
$ asdf --version
```

The output should be `v0.8.1` or similar

## Installing Ruby with `asdf` (in Ubuntu and MacOS)

Now that `asdf` is installed, lets install `ruby`

```bash
$ asdf plugin-add ruby

$ asdf install ruby 3.0.1

$ asdf global ruby 3.0.1
```

Check that ruby was installed correctly

```
$ ruby -v
```

Version '3.0.1' should be output

## Installing Ruby on Windows 10

To install Ruby on Windows 10, go to [https://rubyinstaller.org/](https://rubyinstaller.org/) and download and run the ruby installer.

For more comprehensive instructions, follow this [link](https://dummies.com/programming/ruby/how-to-install-and-run-ruby-on-windows)

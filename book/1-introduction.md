# Introduction

Welcome to _Concise Rails 6_, a fast paced and enhanced tutorial
designed to explain the core concepts of Rails in a very practical
way.

## What is Ruby on Rails

Ruby on Rails is popular web framework that is written in the Ruby
programming language that allows developers to quickly build
powerful and robust web applications. It’s commonly referred to
as Rails and often abbreviated as RoR.

Everything in Rails is designed to make developers’ lives easier by
making assumptions about what they need to get started when they
create a new web application. It allows developers to write less code
while at the same time accomplish more.

Ruby on Rails (RoR) was created in 2003 by David Heinemeier Hansson (aka DHH) when he was working on a project management tool
(now known as Basecamp). However, it wasn’t until 2004 that he
extracted the source and released it as an open-source project.

In 2005, version 1 of Ruby on Rails was officially released. Fast
forward about 16 years, Rails is now on version 6.1 (at the time of
this writing) and has been tested and proven by huge names such as Hulu, Zendesk, Soundcloud, Shopify, Groupon, Airbnb and Github -
just to name a few.

To be proficient with Rails you need a good understanding of Ruby since RoR itself is based on the Ruby programming language. Therefore, the following section is dedicated to the fundamental concepts of Ruby that are essential to Rails development.

## Installations

Before going further, lets install `ruby` in our system. I will be using the Linux Ubuntu operating system in this book, therefore most of the installation instructions presented here are for Ubuntu. However, I have also provided links for setup instructions for windows 10 and macOS operating systems.

We are going to install Ruby using the [asdf](https://asdf-vm.com) version manager. `asdf` is an extendable version manager with support for Ruby, Node.js, Elixir, Erlang & more. It manages multiple language runtime versions on a per-project basis.

As a Rails developer, you might find yourself working on projects that use different versions of ruby (e.g Ruby 2.7 and Ruby 3.0). In that case, you will need a version manager (like `asdf` or `rbenv`) to manage and install the different versions of ruby in your system.

### Installing `asdf` in Ubuntu 18.04 or later

Open your terminal and run the following commands

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1

echo -e '\n. $HOME/.asdf/asdf.sh' > .bashrc

echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc

source ~/.bashrc

# Check if asdf installed correctly:

asdf --version

# The output should be `v0.8.1`
```

### Installing `asdf` in macOS Big Sur or Catalina

You can install `asdf` using Homebrew in your terminal

```bash
brew install asdf

# Add asdf to the .zshrc file
echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> ~/.zshrc
```

Close and re-open the terminal window for the changes to the `~/.zshrc` file to be recognized

```bash
# Check if asdf installed correctly:

asdf --version

# The output should be `v0.8.1` or similar
```

### Installing Ruby with `asdf` (in Ubuntu and MacOS)

Now that `asdf` is installed, lets install `ruby`

```bash
asdf plugin-add ruby

asdf install ruby 3.0.1

asdf global ruby 3.0.1

# Check that ruby was installed correctly
ruby -v

# Version '3.0.1' should be output
```

### Installing Ruby on Windows 10

To install Ruby on Windows 10, go to [https://rubyinstaller.org/](https://rubyinstaller.org/) and download and run the ruby installer.

For more comprehensive instructions, follow this [link](www.dummies.com/programming/ruby/how-to-install-and-run-ruby-on-windows)

## Ruby Basics

Ruby is a general purpose, dynamic and object-oriented language created in 1993 by Yuhikiro Matsumoto. Unlike C or Java which are compiled languages, Ruby is an interpreted language.

### Running ruby in `irb`

To start the ruby interpreter, open the terminal and run

```bash
irb
```

Inside `irb`

```ruby
puts "Hello World"
```

![](./hello-irb.png)

A ruby comment starts with a '#' symbol. Comments are ignored by the ruby interpreter.

`puts` is a method that prints out a string to the standard output (the terminal in this case). It takes in a string to be printed.

To exit from `irb` type `exit` and press enter (or Return)

### Running a ruby source file

Create a directory to hold our code files

```bash
mkdir ruby-basics

cd ruby-basics
```

Now create a file to hold our 'Hello, World' program

```bash
touch hello.rb
```

Inside `hello.rb`, put the following code

```ruby
puts "Hello, World!"
```

To run a ruby program, type `ruby` followed by the filename containing the program.

```bash
ruby hello.rb
```

![](./hello.png)

### Strings

Strings in Ruby can be double-quoted or single-quoted. However, single-quoted strings in ruby do not allow for string interpolation (i.e we cannot inject variables in a single-quoted string to make it dynamic). Double-quoted strings on the other hand allow for string interpolation.

```bash
touch greet.rb
```

Inside `greet.rb`, type the following code

```ruby
puts "What is your name?"

# get input from the user and store it the name variable
name = gets

# greet the user
puts "Hello, #{name}"  # note the string interpolation
```

Run the program

```bash
ruby greet.rb
```

![](./greet.png)

`gets` is a method in ruby that gets input from the user.

Try out the following examples in `irb` to learn more string methods

```ruby
name = "Blessed"

# Convert the string to lowercase
puts a.downcase # outputs "blessed"

# Convert the string to uppercase
puts a.upcase # outputs "BLESSED"

# Reverse the string
puts a.reverse # ouputs "desselB"

# You can also chain methods in ruby
puts a.reverse.upcase # ouputs "DESSELB"

# Convert the string to an array
puts a.split("") # outputs ["B", "l", "e", "s", "s", "e", "d"]
```

### Numbers

Ruby supports different kinds of nsumbers: Integers, Floats, Decimals and Complex Numbers.

Lets create a program to add two numbers together

```bash
touch add_numbers.rb
```

`add_numbers.rb`

```ruby
puts "Enter first number"

a = gets.to_f

puts "Enter second number"

b = gets.to_f

total = a + b

puts "a + b = #{total}"
```

Run the program

```bash
ruby add_numbers.rb
```

![](./add_numbers.png)

`gets` returns the user input as a String. To convert from a string to a float (a real number), Ruby provides the `to_f` method.

To convert a value to an Integer use `to_i`

```ruby
puts "23".to_i     # Outputs 23

puts 10.5.to_i     # Outputs 10
```

Try the following code samples in irb to do basic math operations in Ruby.

```ruby
a = 30
b = 20
# add two numbers
puts a + b

# subtract two numbers
puts a - b

# multiply two numbers
puts a * b

# perform integer division
puts a / b

# perform float division (i.e actual division)
puts a / b.to_f

# Get a square root of a number
puts Math.sqrt(a)
```

Note that in the last statement in the code samples above, we are using a `sqrt` method from the `Math` module. Methods in ruby are defined inside modules(or classes). The `puts` and `gets` methods we used previously are defined inside the `Kernel` module which is accessible by default in a Ruby program.

```ruby
Kernel.puts "Hello, World"

# the 'Kernel' methods are directly accessible in a ruby program
# therefore there is no need to prefix the call to 'puts' with the 'Kernel.'

puts "Hello, World"
```

Try out more examples

```ruby
a = 3.567

# Round to two decimal places
puts a.round(2) # outputs 3.57

# Round to the nearest integer
puts a.round # outputs 4
```

## Booleans

A boolean is either `true` or `false`. Booleans are used especially in conditionals to check the truthiness of an expression.

Try out the following examples in `irb` to learn the conditional statements.

```ruby
tired = true

if tired
  puts "Take some rest"
end

age = 16

if age >= 16
  puts "You can drive"
else
  puts "You cannot drive"
end

# `unless` is the opposite of `if`

unless tired
  puts "Keep on working"
end

# if you have multiple conditions, you can use the `case` statement
score = 81
case score
  when 90..100
    puts "Excellent work"
  when 80..90
    puts "Good work"
  when 70..80
    puts "Above average"
  when 60..70
    puts "Pass"
  else
    puts "Fail"
  end
```

The expression `90..100` is an inclusive range, so the first branch will evaluate when `(90 <= score <= 100)`. Another type of range is written like so `90...100`, this range does not include the upper bound (it only covers values 90 to 99). Any conditional expression (including regular expressions) can be used in a case statement.

### Arrays

Arrays in ruby can hold objects of different data types and they dynamically shrink or grow in size depending on the number of inserted items

Try out the following in `irb`

```ruby
random_array = [1,3, "Blessed", 4.5, true]

# Get the size of the array
puts random_array.size

# Retrieve the first item of an array
puts random_array.first

# the second item
puts random_array.second

# the last item
puts random_array.last

# Print all the items in the array
random_array.each do |item|
  puts item
end

# Convert a range to an Array
my_range = 1..10

# use the `to_a` method on the Range
my_range.to_a # outputs [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# join the items in an array
fruits = ["grape", "banana", "orange", "mango"]

# use the `join` method on the Array
puts fruits.join(" and ") # outputs "grape and banana and orange and mango"
```

The `each` method passes the successive elements of an Array into a block. The `do` `end` construct in the example above marks a ruby `block`.

### Hashes

A hash holds key-value pairs

```ruby
# Creating a hash

my_hash = {a: 12, b: 45}

# You can look up values by their keys

puts my_hash[:a] # outputs 12

puts my_hash[:b] # outputs 45

# Looking up a non-existent key in a Hash returns nil
puts my_hash[:c] # ouputs nil

# Change a hash item
my_hash[:b] = 20

puts my_hash[:b] # outputs 20

# Add new item
my_hash[:f] = "Something Else"

puts my_hash[:f] # outputs "Something Else"

# print the values in a hash
my_hash.each do |key, value|
  puts "key = #{key} and value = #{value}"
end
```

The `each` method of a hash `yields` two values to the block for each iteration (i.e the key and the value).

### Methods

Methods are used to hold pieces of code for reuse. The following example uses

```ruby
def greet_user
  puts "Hello User"
end

greet_user # outputs "Hello User"
```

Methods can also accept parameters

```ruby
def greet2(name)
  puts "Hello #{name}"
end

greet2 "Blessed" # outputs "Hello Blessed"
```

Methods can also return values

```ruby
def add(a, b)
  a + b
end

# assign the return value of the method to a variable
total = add(10, 5)
puts total # outputs 15
```

The last expression of a ruby method is the return value of the method, so an explicit `return` keyword is not usually required.

### Classes

Ruby is an object-oriented language, everything is an object in Ruby. Even the booleans `true` and `false` are regarded as objects. Every object has a class. A class is a blueprint for an object. Classes can inherit/subclass each other forming a parent-child relationship. `BasicObject` is the parent class of all objects in Ruby.

```ruby
# create a class
class Animal
end

# create an animal object
# the new method of a class is used to instantiate a new object from the class
lion = Animal.new

# check the class of the object
puts lion.class # output "Animal"

# you can define methods in a class
# the initialize method is called when an object is created from a class
class Animal
  # The variables that start with '@' are called instance variables.
  # Instance variables are accessible from within the class and they belong to the instance.
  def initialize(name)
    @name = name
  end

  def name
    @name
  end
end

lion = Animal.new("Simba")

# call the method `name` to return the instance variable `@name`
puts lion.name # outputs "Simba"

# create another class
class Person
  attr_reader :name, :age
  def initialize(name, age)
    @name = name
    @age = age
  end
end

p1 = Person.new("Blessed", 25)
puts p1.name # outputs "Blessed"
puts p1.age # outputs 25
```

`attr_reader` is a method that creates getter methods to return the related instance variable.

The following expression

```ruby
attr_reader :age
```

Dynamically creates the following method in the class

```ruby
def age
  @age
end
```

Classes can be openned in Ruby to add new features and methods.

```ruby
# lets re-open the Person class to add a `name` setter
class Person
  def name=(name)
    @name = name.capitalize
  end
end

p1.name = "michael"
puts p1.name # outputs "Michael"
```

Methods in ruby can end with punctuation signs such as '?' and '='

`attr_writer` just like `attr_reader` creates a setter method for an instance variable automatically.

Lets modify the `Person` class to include a setter for the 'age' using `attr_writer`

```ruby
class Person
  attr_writer :age
end

# set the age to another value
p1.age = 35
puts p1.age # outputs 35
```

`attr_accessor` is a combination of `attr_reader` and `attr_writer`

```ruby
class Car
  attr_accessor :model, :make
end

c1 = Car.new
c1.model = "Fit"
c1.make = "Honda"

puts c1.model # outputs "Honda"
puts c1.make # outputs "Fit"
```

Classes can inherit from each other

```ruby
class Animal
  attr_accessor :name, :sound
  def initialize(name, sound)
    @name = name
    @sound = sound
  end
end

# define a dog class that subclasses 'Animal'
# the Dog class inherits all the methods defined in its parent
class Dog < Animal
end

d = Dog.new("Spot", "bark")
puts d.name # outputs "Spot"
puts d.sound # outputs "bark"

# child classes can override parent methods

class Dog < Animal
  attr_accessor :color
  def initialize(name, sound, color)
    super # `super` calls the parent class' initialize method
    @color = color
  end
end

# Now a dog has a color
d = Dog.new "Spot", "bark", "brown"
puts d.color # outputs "brown"
```

### Modules

Modules are used to organize related methods and classes.

```ruby
module MyModule
  def greet
    puts "Hello"
  end
end

# methods in a module can be included in a class
class MyClass
  include MyModule
end

m = MyClass.new

# call the module method
m.greet # outputs "Hello"
```

Modules are also used to namespace classes and methods.

```ruby
class Library
  class Book
    attr_accessor :title

    def initialize(title)
      @title = title
    end
  end
end

book = Library::Book("Concise Rails")
puts book.title # outputs "Concise Rails"
```

### Blocks

A ruby **block** is a way of grouping statements and it appears adjacent to a method call; the block is written starting on the same line as the method call's last parameter (or the closing parenthesis of the parameter list). The ruby standard is to use braces for single-line blocks and do..end for multi-line blocks. Inside the method, you can call the block using the `yield` keyword with a value.

```ruby
# define a method that calls a block
def my_block
  yield
end

# call the method with a block
my_block { puts "Hello there" } # braces syntax

# do..end syntax
my_block do
  puts "What is your name"
  name = gets
  puts "Hello #{name}"
end

# You can also provide parameters to `yield` and these
# will be passed to the block
def my_other_block
  yield("Blessed", 25)
end

my_other_block do |name, age|
  puts "#{name} is #{age} years old"
end
```

Most methods in Ruby accept blocks. The following are a few examples

```ruby
# perform an operation 5 times
# `times` is an method on integers (i.e defined in the Integer class)
# `times` accepts a block and it executes it a given number of times
5.times do
  puts "Hello there"
end

# 'times' can also yield a parameter to a block
# This parameter varies from 0 - (n-1) where n is the Integer
5.times do |i|
  puts "Iteration #{i}"
end

# Array `each` method yields successive items of an Array to a block
[1,3,4].each do |num|
  puts num
end
```

### Symbols

A symbol is generally used as a unique identifier. You will see heavy usage of symbols when we start to talk about rails. A symbol like an number is immutable, i.e it doesn't change. Just like 2 will always be 2, also the symbol :a will always be :a (i.e same `object_id`)

```ruby
# Creating a symbol

:name

:name.class # outputs "Symbol"

# strings are mutable
"a".object_id # outputs 13400

# the string "a" changes
"a".object_id # outputs 13420

# symbols are immutable
:a.object_id # outputs 780508

# the symbol :a doesn't change
:a.object_id # outputs 780508
```

## Rails Basics

Now we have covered the basics of Ruby, we are now ready to move into Rails.

Lets install Rails

```bash
gem install rails -v 6.1.4
```

To create a new rails project, you use the following syntax

```bash
rails new {project_name} <options>
```

Lets a create a simple project to manage a list of the tasks we want to do.

Before we create a rails project, we need to install a database. Rails uses sqlite3 by default, but we dont want to use that, as it is not suitable for production. It is recommended to develop with the same database as you would use in production.

In this book, we will be using PostgreSQL as our database because it is a very powerful and open-source database management system with lots of advanced features

### Install PostgreSQL in Ubuntu

```bash
# Create the file repository configuration
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update the package lists
sudo apt-get update

# Install PostgreSQL version 12
sudo apt-get -y install postgresql-12 libpq-dev

`[sudo] password for username: [password]`

# Enter password when prompted
```

**To install PostgreSQL in MacOS and Windows 10, use the following links**

1. For MacOS **[click here](www.postgresqltutorial.com/install-postgresql-macos/)**
2. For Windows 10 **[click here](www.2ndquadrant.com/en/blog/pginstaller-install-postgresql/)**

```bash
rails new todo_list -d postgresql

# cd into project
cd todo_list

# create database
rails db:create

# Run the development server
rails server
```

### Application Structure

This is the application structure of rails application

![](./app-structure.png)

**app** - for models, controllers, views and other components of our rails application. We will spend most of our time in this directory.

**bin** - contains the executables for our project such as (webpack, rails, rake, yarn etc.)

**config** - for the configuration files (e.g routes, initializers) for our application.

**db** - contains database migration and seed files

**lib** - will contain our Ruby code libraries that don't fit properly in either models, controllers or concerns.

**log** - contains the log files

**node_modules** - contains the javascript modules installed from npm.

**public** - everything in this directory is served directly by our rails server.

**storage** - for uploaded files

**test** - for test code

**tmp** - for temporary files

### Todo Model

Create a model to hold the Todo items. A model in rails is a ruby class that inherits from ActiveRecord. ActiveRecord is a database access layer for Rails. Because it inherits from Active Record, a rails model can access and communicate seamlessly with a database.

An active record model represents a database column. An active record instance represents a database row.

To create a rails model, you use the following syntax

```bash
rails model {model_name} <field_1:type> <field_2:type> ... <field_n:field>
```

A todo item will have a title and a description.

```bash
rails g model Todo title:string description:text
```

This command generates the following files:

- migration file - which contains changes to be made to the database

- model file - which contains an active-record model that is reponsible for interacting with the database

- test file - for tests

- fixtures file - for adding test data to the database

![](./todo_model.png)

### Todo Model

`app/models/todo.rb`

```ruby
class Todo < ApplicationRecord
end
```

The `Todo` model inherits from `ApplicationRecord` which inturn subclasses the `ActiveRecord` class. Infact, all our database models inherit from `ApplicationRecord`

`app/models/application_record.rb`

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
```

Application is an abstract class, meaning that it doesn't represent a database table. It only provides database access features to its children (the subclasses that represent database tables)

### CreateTodos Migration

A migration file describes the changes that should be made to the database. Migration files live in the `db/migrate` directory.

A migration file is prefixed with a timestamp for when it was created. This helps in keeping the history of the database and for rails to know the order of the migrations when migrating the database up or rolling it back.

Rails intelligently determines the name of the migration class based on the database table being created. For instance, in this case we are creating a `Todo` model, so rails will know that it has to create a table named `todos` in the database. (The convention of Rails is to name the database table using the plural name of the model). Because creating a new model creates a new table, rails will name the class of the migration `CreateTodos` (to denote that the migration is creating a `todos` database table)

Let's examine the generated migration file.

`db/migrate/{timestamp}_create_todos.rb`

```ruby
class CreateTodos < ActiveRecord::Migration[6.1]
  def change
    create_table :todos do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
```

The `change` or `up` or `execute` method of a migration is exceuted when the migration is applied. Inside this method, we describe the changes we want to be made to the database.

In our `CreateTodos` migration inside the `change` method, we call a method called `create_table`. `create_table` creates a new database table and it yields the table object to the block which is then used to define the columns we want.

`t.string :title` - means that we are creating a `VARCHAR` column named 'title'. This column will hold the titles of our todo items.

`t.text :description` - creating a description column of type `TEXT` in our database

`t.timestamps` - creates the `created_at` and `updated_at` fields that are automatically updated when the model is created or modified.

Now let's run the migration (ensure that you are in the root directory for the project)

```bash
rails db:migrate
```

The output will show that a `todos` database table was created.

![](./todo-migration.png)

After the first migration is applied, the `db/schema.rb` file will be created and populated with the state of the database

`db/schema.rb`

```ruby
ActiveRecord::Schema.define(version: 2021_09_10_123126) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "todos", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
```

As you can see from the schema file, our database has a `todos` table with four fields (the `title`, `description`, `created_at` and `updated_at`). The schema file shows the current status of the database

With each migration applied, the schema file is updated by rails to always reflect the current status of the database. This file is used to re-create the database.

Now that our migration is applied, let's play with ActiveRecord a little. To do this, we will use a `rails console` which is essential an `irb` console but with the Rails environment in it.

Open the rails console

```bash
rails console
```

```ruby
# create a new todo in memory
# an active record model is instantiated by using the 'new' method just like any other ruby class.
# it accepts the field values as arguments to the 'new' method
todo1 = Todo.new(title: "Watch TV", description: "Watch my favo
rite TV show")

# the todo is not yet saved to the database so its id is nil
puts todo1.id # outputs nil

puts todo1.persisted? # outputs false

# to save the todo in the database, call save
todo1.save

# now the todo has an id

puts todo1.id # outputs 1

puts todo1.persisted? # outputs true

# an activerecord instance can be initialized and persisted to the database in one fell swoop using the `create` method

# lets create another todo
todo2 = Todo.create(title: "Read a book", description: "Finish off chapter 5 of Concise Rails 6")

puts todo2.id # outputs 2

# To get all todos from the database run the 'all' method
todos = Todo.all

# Get the number of todos
puts Todo.count # outputs 2

# Get a todo by id
t = Todo.find(1)

# if the id is not found, an `ActiveRecord::RecordNotFound` exception is raised. We will talk more about handle exceptions later.

# search for todo whose title is 'Read a book'

t2 = Todo.where(title: 'Read a book')

# update a todo
t2.title = 'Read a very good book'

t2.save

# destroy a todo
t2.destroy

# now only 1 todo is left
Todo.count # outputs 1

# now lets create another todo (but with an empty title and description)

blank_todo = Todo.new

blank_todo.save
```

The blank todo was saved to the database without any problems. However, this is not a good thing as a blank todo is meaningless. We define validations inside the model To prevent invalid data in our models.

The first validation we want to add to both the `title` and the `description` is the `presence` validation. This validation ensures that a field is not blank, otherwise an error is raised and the model is prevented from being inserted into the database.

`todo.rb`

```ruby
class Todo < ApplicationRecord
  validates :title, presence: true
  validates :description, presence: true
end
```

The `validates` method accept a field name and a list of validation options. With this code in place, our todos cannot be saved without a `name` or a `description`.

Lets try it out in the `rails console`

```ruby
# reload the console
!reload

blank_todo = Todo.new
blank_todo.save # outputs false

# check the valid? status of the model
blank_todo.valid? # false

# check the errors
blank_todo.errors # a hash with errors is return

# get the full error messages
blank_todo.errors.full_messages

# output => ["Title can't be blank", "Description can't be blank"]

# now lets add the title and description and re-save the model again
blank_todo.title = 'Some title'

# check the error messages again
blank_todo.errors.full_messages

# output => ["Description can't be blank"]

# the title error message is now gone

blank_todo.description = 'Some description'

blank_todo.save # outputs true
```

the `save` method of the active record model returns `true` if a model is saved successfully to the database and `false` if it isn't.

Lets add another validation to ensure that our todo titles are unique thorugh out the database.

`todo.rb`

```ruby
class Todo < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  validates :description, presence: true
end
```

We simply add the uniqueness option to the `validates :title` line. You can now `reload!` the `rails console` and check that you can no longer have todos with the same titles. With just a few lines of code, we have made our model robust and protected our database from having invalid meaningless data. This is the power of Rails!.

### Creating a Controller

Now lets create a controller to orchestrate the application when a user makes a request to our application.

The general syntax for creating a controller is as follows:

```bash
rails g controller {controller_name} <action1> <action2>
```

```bash
rails g controller Todos new index
```

This following files/folders are generated:

- controller file - contains the controller class

- controller test file - contains the test code for the controller

- helper file - contains helpers module

- views files - these contain the `erb` templates for data representation. A view file is created for each action.

![](./todos-controller.png)

An action is a method inside a controller that handles a specific request

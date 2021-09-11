# Starting Ansaz

In this chapter, we will begin building the application that we will be working on throughout this book. The application we are going to build is called *Ansaz*.

**Ansaz** is a web application that allow users to ask questions and get answers from other users. It has the following features:

- Users can ask questions and get answers from other users

- Users can search for questions

- Users can comment on the answers

- Users can star questions and the answers they think are most helpful. 

- Answers to questions are ranked according to their number of stars.

- Users can create private groups where they can ask questions on a specific subject or topic. 

- Groups have staff members who moderate content on the group.

## Create Ansaz

In the terminal, create a new rails application with postgresql as the database. 

```bash
$ rails new ansaz -d postgresql
```
cd into `ansaz`

```bash
$ cd ansaz
```

Create the database

```bash
$ rails db:create
```

Open the project in VSCode (or any editor of your choosing)

```
$ code .
```

Run the development server

```
$ rails s
```


## 




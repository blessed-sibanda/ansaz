# 6 Answers

## Scaffold answers

```bash
rails g scaffold answer user:references question:belongs_to accepted:boolean --skip-stylesheets
```

Update the `accepted` field in the migration to have a default value of `false`

```ruby
class CreateAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :answers do |t|
      t.references :user, null: false, foreign_key: true
      t.belongs_to :question, null: false, foreign_key: true
      t.boolean :accepted, default: false

      t.timestamps
    end
  end
end
```

```bash
rails db:migrate
```

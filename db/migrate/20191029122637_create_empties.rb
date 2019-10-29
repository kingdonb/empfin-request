class CreateEmpties < ActiveRecord::Migration[6.0]
  def change
    create_table :empties do |t|

      t.timestamps
    end
  end
end

create table :cars do |t|
  t.column :brand, :string
  t.column :model, :string
end

create table :passengers do |t|
  t.column :car_id, :int
  t.column :name, :string
end

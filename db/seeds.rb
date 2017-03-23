Plan.destroy_all
Plan.create([
  {
    title: 'Acquaintance',
    description: '1 motivational text message a month',
    price: 1.99
  },
  {
    title: 'Friend',
    description: '1 motivational text message a week',
    price: 5.99
  },
  {
    title: 'BFFL',
    description: '1 motivational text message a day',
    price: 10.99
  }
])

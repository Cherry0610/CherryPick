// /CherryPick_backend/data.js

const groceryData = [
  // Apples
  { id: 1, name: "Granny Smith Apples (1kg)", store: "Tesco Online", price: 6.50, link: "link-tesco-apples", location: "Online" },
  { id: 2, name: "Granny Smith Apples (1kg)", store: "Giant E-Shop", price: 7.20, link: "link-giant-apples", location: "Online" },

  // Eggs
  { id: 4, name: "Fresh Eggs (10 pack)", store: "Tesco Online", price: 12.00, link: "link-tesco-eggs", location: "Online" },
  { id: 5, name: "Fresh Eggs (10 pack)", store: "Giant E-Shop", price: 10.50, link: "link-giant-eggs", location: "Online" },

  // Milk
  { id: 7, name: "Full Cream Milk (1L)", store: "Tesco Online", price: 4.80, link: "link-tesco-milk", location: "Online" },
  { id: 8, name: "Full Cream Milk (1L)", store: "Giant E-Shop", price: 5.10, link: "link-giant-milk", location: "Online" },
];

const storeLocations = [
  { id: 1, name: "Tesco Superstore PJ", address: "Jalan 21/1", lat: 3.1234, lng: 101.6789 },
  { id: 2, name: "Giant Hypermarket Shah Alam", address: "Persiaran Dato Menteri", lat: 3.0123, lng: 101.5432 },
  { id: 3, name: "Village Grocer Bangsar", address: "Jalan Telawi 3", lat: 3.1500, lng: 101.6700 },
];

module.exports = { groceryData, storeLocations };
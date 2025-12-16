// /CherryPick_frontend/script.js

// 1. Define the base URL of your running backend server
const BACKEND_URL = 'http://localhost:3000';

// 2. Get the necessary elements from the HTML
const searchForm = document.getElementById('searchForm');
const searchInput = document.getElementById('searchInput');
const resultsContainer = document.getElementById('resultsContainer');

// --- Main Function to Handle Search Submission ---
searchForm.addEventListener('submit', function(event) {
    // Prevent the form from refreshing the page
    event.preventDefault();

    const searchTerm = searchInput.value.trim();
    if (searchTerm) {
        fetchPrices(searchTerm);
    }
});

// --- Function to Communicate with the Backend ---
async function fetchPrices(query) {
    // Clear previous results and show a loading message
    resultsContainer.innerHTML = '<p>Loading prices...</p>';

    try {
        // Use the fetch API to call your backend's price endpoint
        const response = await fetch(`${BACKEND_URL}/api/prices?q=${query}`);

        // Check if the response was successful
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        // Parse the JSON data from the backend
        const data = await response.json();

        // Display the results
        displayResults(data.data, query);

    } catch (error) {
        console.error("Could not fetch data:", error);
        resultsContainer.innerHTML = '<p style="color:red;">Error fetching data. Is the backend server running on port 3000?</p>';
    }
}

// --- Function to Display Data on the Page ---
function displayResults(items, query) {
    resultsContainer.innerHTML = ''; // Clear loading message

    if (items.length === 0) {
        resultsContainer.innerHTML = `<p class="placeholder">No results found for "${query}". Try 'milk', 'eggs', or 'apples'.</p>`;
        return;
    }

    // Determine the cheapest price to add the badge
    const cheapestPrice = items.length > 0 ? items[0].price : null;

    items.forEach(item => {
        // Check if this item is the cheapest
        const isCheapest = item.price === cheapestPrice;

        const card = document.createElement('div');
        card.className = 'result-card';

        card.innerHTML = `
            <span class="item-name">
                ${isCheapest ? '<span class="cheapest-badge">Cheapest!</span>' : ''}
                ${item.name}
            </span>
            <div class="store-info">
                <div>${item.store}</div>
                <div class="price">RM ${item.price.toFixed(2)}</div>
            </div>
        `;

        resultsContainer.appendChild(card);
    });
}
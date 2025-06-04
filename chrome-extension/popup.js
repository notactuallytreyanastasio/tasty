// API Configuration
const API_BASE_URL = 'http://localhost:4000/api';

// DOM Elements
const authSection = document.getElementById('auth-section');
const bookmarkSection = document.getElementById('bookmark-section');
const loginForm = document.getElementById('login-form');
const bookmarkForm = document.getElementById('bookmark-form');
const pageTitle = document.getElementById('page-title');
const pageUrl = document.getElementById('page-url');
const titleInput = document.getElementById('title');
const descriptionInput = document.getElementById('description');
const tagsInput = document.getElementById('tags');
const isPublicInput = document.getElementById('is-public');
const successMessage = document.getElementById('success-message');
const errorMessage = document.getElementById('error-message');

// Initialize popup
document.addEventListener('DOMContentLoaded', async () => {
  try {
    // Get current tab information
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    
    if (tab) {
      pageTitle.textContent = tab.title || 'Untitled';
      pageUrl.textContent = tab.url || '';
      titleInput.value = tab.title || '';
      
      // Try to extract description from meta tags
      try {
        const results = await chrome.scripting.executeScript({
          target: { tabId: tab.id },
          func: extractPageInfo
        });
        
        if (results && results[0] && results[0].result) {
          const pageInfo = results[0].result;
          if (pageInfo.description) {
            descriptionInput.value = pageInfo.description;
          }
        }
      } catch (err) {
        console.log('Could not extract page info:', err);
      }
    }
    
    // Check authentication status
    const isAuthenticated = await checkAuthStatus();
    if (isAuthenticated) {
      showBookmarkSection();
    } else {
      showAuthSection();
    }
  } catch (error) {
    console.error('Failed to initialize popup:', error);
    showError('Failed to load extension');
  }
});

// Extract page information
function extractPageInfo() {
  const description = document.querySelector('meta[name="description"]')?.content ||
                     document.querySelector('meta[property="og:description"]')?.content ||
                     '';
  
  return { description };
}

// Check authentication status
async function checkAuthStatus() {
  try {
    const result = await chrome.storage.local.get(['authToken']);
    return !!result.authToken;
  } catch (error) {
    console.error('Failed to check auth status:', error);
    return false;
  }
}

// Show authentication section
function showAuthSection() {
  authSection.classList.remove('hidden');
  bookmarkSection.classList.add('hidden');
}

// Show bookmark section
function showBookmarkSection() {
  authSection.classList.add('hidden');
  bookmarkSection.classList.remove('hidden');
}

// Handle login form submission
loginForm.addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;
  
  try {
    const response = await fetch(`${API_BASE_URL}/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email, password })
    });
    
    if (response.ok) {
      const data = await response.json();
      await chrome.storage.local.set({ authToken: data.token });
      showBookmarkSection();
    } else {
      showError('Invalid email or password');
    }
  } catch (error) {
    console.error('Login failed:', error);
    showError('Login failed. Please try again.');
  }
});

// Handle bookmark form submission
bookmarkForm.addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const saveBtn = e.target.querySelector('.save-btn');
  saveBtn.disabled = true;
  saveBtn.textContent = 'Saving...';
  
  try {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    
    const bookmarkData = {
      url: tab.url,
      title: titleInput.value.trim(),
      description: descriptionInput.value.trim(),
      is_public: isPublicInput.checked,
      tags: tagsInput.value.split(',').map(tag => tag.trim()).filter(tag => tag)
    };
    
    const result = await chrome.storage.local.get(['authToken']);
    const authToken = result.authToken;
    
    const response = await fetch(`${API_BASE_URL}/bookmarks`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${authToken}`
      },
      body: JSON.stringify({ bookmark: bookmarkData })
    });
    
    if (response.ok) {
      showSuccess('Bookmark saved successfully!');
      // Close popup after a short delay
      setTimeout(() => {
        window.close();
      }, 1500);
    } else if (response.status === 401) {
      // Token expired, show auth section
      await chrome.storage.local.remove(['authToken']);
      showAuthSection();
      showError('Please sign in again');
    } else {
      const errorData = await response.json().catch(() => ({}));
      showError(errorData.message || 'Failed to save bookmark');
    }
  } catch (error) {
    console.error('Failed to save bookmark:', error);
    showError('Failed to save bookmark. Please try again.');
  } finally {
    saveBtn.disabled = false;
    saveBtn.textContent = 'Save Bookmark';
  }
});

// Show success message
function showSuccess(message) {
  successMessage.textContent = message;
  successMessage.classList.remove('hidden');
  errorMessage.classList.add('hidden');
}

// Show error message
function showError(message) {
  errorMessage.textContent = message;
  errorMessage.classList.remove('hidden');
  successMessage.classList.add('hidden');
}

// Handle register link (opens registration page)
document.getElementById('register-link').addEventListener('click', (e) => {
  e.preventDefault();
  chrome.tabs.create({ url: 'http://localhost:4000/users/register' });
});
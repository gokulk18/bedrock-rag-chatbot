import { CONFIG } from './config.js';

const STORAGE_KEYS = {
  session: 'bedrock-chat-session-id',
  messages: 'bedrock-chat-messages',
  theme: 'bedrock-chat-theme',
};

const PROMPT_SUGGESTIONS = [
  {
    title: 'What is Terraform?',
    detail: 'Start with the basics and core purpose.',
  },
  {
    title: 'What are Modules?',
    detail: 'Understand reusable configuration blocks.',
  },
  {
    title: 'Explain Terraform State',
    detail: 'Learn how Terraform tracks resources.',
  },
  {
    title: 'How do Providers work?',
    detail: 'See how plugins connect Terraform to services.',
  },
];

const state = {
  sessionId: loadSession(),
  messages: loadMessages(),
  isProcessing: false,
  isTyping: false,
  pendingRetryQuestion: null,
  theme: localStorage.getItem(STORAGE_KEYS.theme) || (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'),
};

document.addEventListener('DOMContentLoaded', initializeChat);

function initializeChat() {
  applyTheme(state.theme);
  bindEvents();
  render();
  focusInput();
}

function bindEvents() {
  const chatForm = document.getElementById('chat-form');
  const promptInput = document.getElementById('prompt-input');
  const clearButton = document.getElementById('clear-chat');
  const themeToggle = document.getElementById('theme-toggle');
  const conversation = document.getElementById('conversation');

  chatForm.addEventListener('submit', handleSubmit);
  promptInput.addEventListener('keydown', handleTextareaKeydown);
  promptInput.addEventListener('input', autoResizeTextarea);
  clearButton.addEventListener('click', clearConversation);
  themeToggle.addEventListener('click', toggleTheme);
  conversation.addEventListener('click', handleConversationActions);

  autoResizeTextarea();
}

function handleConversationActions(event) {
  const promptCard = event.target.closest('.prompt-card');
  if (promptCard) {
    const prompt = promptCard.dataset.prompt;
    const input = document.getElementById('prompt-input');
    input.value = prompt;
    autoResizeTextarea();
    input.focus();
    return;
  }

  const copyButton = event.target.closest('.copy-button');
  if (copyButton) {
    copyMessage(copyButton.dataset.messageId);
    return;
  }
}

async function handleSubmit(event) {
  event.preventDefault();

  const input = document.getElementById('prompt-input');
  const question = input.value.trim();

  if (!question) {
    showError('Please enter a question before sending.');
    return;
  }

  if (state.isProcessing) {
    showError('A request is already in progress. Please wait for the current response.');
    return;
  }

  state.isProcessing = true;
  state.isTyping = true;
  state.pendingRetryQuestion = null;
  input.value = '';
  autoResizeTextarea();

  const userMessage = {
    id: createMessageId(),
    role: 'user',
    content: question,
    timestamp: new Date().toISOString(),
    accent: getAccentForUserMessage(),
  };

  state.messages.push(userMessage);
  persistMessages();
  render();
  updateSendButton();

  try {
    const payload = await callApi(question, state.sessionId);
    const botMessage = {
      id: createMessageId(),
      role: 'assistant',
      answer: payload.answer || 'I could not produce an answer.',
      citations: Array.isArray(payload.citations) ? payload.citations : [],
      confidence: payload.confidence || 'High',
      timestamp: payload.timestamp || new Date().toISOString(),
    };

    if (payload.session_id) {
      state.sessionId = payload.session_id;
      saveSession(state.sessionId);
    }

    state.messages.push(botMessage);
    persistMessages();
    state.isTyping = false;
    state.isProcessing = false;
    render();
    updateSendButton();
    showNotification('Response ready.', 'success');
  } catch (error) {
    state.isTyping = false;
    state.isProcessing = false;
    state.pendingRetryQuestion = question;
    render();
    updateSendButton();
    showError(error.message, question);
  }
}

function render() {
  const conversation = document.getElementById('conversation');

  if (state.messages.length === 0 && !state.isTyping) {
    conversation.innerHTML = `
      <section class="welcome-screen">
        <div class="welcome-icon" aria-hidden="true">
          <img src="./assets/chatbot-icon.svg" alt="" />
        </div>
        <div>
          <h2>Terraform Documentation Assistant</h2>
          <p class="subtle">Ask me anything about Terraform, providers, modules, state, or backends. I can help you navigate your documentation quickly.</p>
        </div>
        <div class="prompt-grid">
          ${PROMPT_SUGGESTIONS.map((prompt) => `
            <button type="button" class="prompt-card" data-prompt="${escapeHtml(prompt.title)}">
              <strong>${escapeHtml(prompt.title)}</strong>
              <span>${escapeHtml(prompt.detail)}</span>
            </button>
          `).join('')}
        </div>
      </section>
    `;
  } else {
    const markup = state.messages
      .map((message) => (message.role === 'user' ? renderUserMessage(message) : renderBotMessage(message)))
      .join('');

    conversation.innerHTML = `${markup}${state.isTyping ? renderTypingIndicator() : ''}`;
    scrollToBottom();
  }

  updateSendButton();
  focusInput();
}

function renderUserMessage(message) {
  return `
    <div class="message-row user-row">
      <div class="message-bubble" style="background:${getAccentGradient(message.accent)}">
        <div class="message-content">${escapeHtml(message.content)}</div>
        <div class="message-meta">
          <span>${formatTimestamp(message.timestamp)}</span>
        </div>
      </div>
      <div class="message-avatar" aria-hidden="true">
        <img src="./assets/user-avatar.svg" alt="" />
      </div>
    </div>
  `;
}

function renderBotMessage(message) {
  const citationsMarkup = (message.citations || []).length
    ? `
      <details class="citation-section">
        <summary class="citation-toggle">Sources</summary>
        <div class="citation-list">
          ${(message.citations || []).map((citation) => renderCitation(citation)).join('')}
        </div>
      </details>
    `
    : '';

  return `
    <div class="message-row">
      <div class="message-avatar" aria-hidden="true">
        <img src="./assets/bot-avatar.svg" alt="" />
      </div>
      <div class="message-card">
        <div class="message-content">${escapeHtml(message.answer)}</div>
        <div class="message-toolbar">
          <span class="confidence-badge">Confidence • ${escapeHtml(message.confidence || 'High')}</span>
          <button class="copy-button" type="button" data-message-id="${message.id}">Copy</button>
        </div>
        <div class="message-meta">
          <span>${formatTimestamp(message.timestamp)}</span>
        </div>
        ${citationsMarkup}
      </div>
    </div>
  `;
}

function renderTypingIndicator() {
  return `
    <div class="message-row">
      <div class="message-avatar" aria-hidden="true">
        <img src="./assets/bot-avatar.svg" alt="" />
      </div>
      <div class="message-card typing-card">
        <div class="typing-indicator" aria-label="Bot is thinking">
          <span></span><span></span><span></span>
        </div>
        <div class="typing-label">Bot is thinking...</div>
      </div>
    </div>
  `;
}

function renderCitation(citation) {
  return `
    <div class="citation-card">
      <strong>${escapeHtml(citation.document || 'Source')}</strong>
      <div class="citation-meta">Page ${escapeHtml(citation.page ?? 'n/a')}</div>
      <div>${escapeHtml(citation.text || 'No excerpt available.')}</div>
    </div>
  `;
}

function copyMessage(messageId) {
  const message = state.messages.find((entry) => entry.id === messageId);
  if (!message || !message.answer) {
    showError('No response available to copy.');
    return;
  }

  navigator.clipboard.writeText(message.answer).then(
    () => showNotification('Response copied to your clipboard.', 'success'),
    () => showError('Unable to copy automatically. Please copy manually.'),
  );
}

function clearConversation() {
  state.messages = [];
  state.isTyping = false;
  state.isProcessing = false;
  state.pendingRetryQuestion = null;
  persistMessages();
  render();
  showNotification('Conversation cleared.', 'success');
}

function generateSessionId() {
  if (typeof crypto !== 'undefined' && crypto.randomUUID) {
    return crypto.randomUUID();
  }

  return `session-${Date.now()}-${Math.random().toString(16).slice(2)}`;
}

function saveSession(sessionId) {
  localStorage.setItem(STORAGE_KEYS.session, sessionId);
}

function loadSession() {
  const existing = localStorage.getItem(STORAGE_KEYS.session);
  if (existing) {
    return existing;
  }

  const sessionId = generateSessionId();
  saveSession(sessionId);
  return sessionId;
}

function saveSessionState() {
  saveSession(state.sessionId);
}

function persistMessages() {
  localStorage.setItem(STORAGE_KEYS.messages, JSON.stringify(state.messages));
  saveSessionState();
}

function loadMessages() {
  try {
    const stored = JSON.parse(localStorage.getItem(STORAGE_KEYS.messages) || '[]');
    return Array.isArray(stored) ? stored : [];
  } catch {
    return [];
  }
}

async function callApi(question, sessionId) {
  const url = buildApiUrl();
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
    body: JSON.stringify({
      session_id: sessionId,
      question,
    }),
  });

  let payload = {};
  try {
    payload = await response.json();
  } catch {
    payload = {};
  }

  if (!response.ok) {
    throw new Error(payload.error || payload.detail || `Request failed with status ${response.status}.`);
  }

  return payload;
}

function buildApiUrl() {
  const base = (CONFIG.API_BASE_URL || '').trim();
  if (!base) {
    return '/chat';
  }
  return `${base.replace(/\/$/, '')}/chat`;
}

function showError(message, retryQuestion = null) {
  const container = document.getElementById('notifications');
  const retryMarkup = retryQuestion
    ? `<button type="button" class="notification-action" data-retry="retry">Retry</button>`
    : '';

  container.innerHTML = `
    <div class="notification error">
      <span>${escapeHtml(message)}</span>
      ${retryMarkup}
    </div>
  `;

  const retryButton = container.querySelector('[data-retry="retry"]');
  if (retryButton) {
    retryButton.addEventListener('click', () => {
      const input = document.getElementById('prompt-input');
      input.value = retryQuestion;
      autoResizeTextarea();
      input.focus();
      handleSubmit({ preventDefault() {} });
    });
  }
}

function showNotification(message, type = 'success') {
  const container = document.getElementById('notifications');
  container.innerHTML = `
    <div class="notification ${type}">
      <span>${escapeHtml(message)}</span>
    </div>
  `;

  window.clearTimeout(showNotification.timeoutId);
  showNotification.timeoutId = window.setTimeout(() => {
    container.innerHTML = '';
  }, 3200);
}

function scrollToBottom() {
  const panel = document.getElementById('conversation-panel');
  if (panel) {
    panel.scrollTop = panel.scrollHeight;
  }
}

function toggleTheme() {
  state.theme = state.theme === 'dark' ? 'light' : 'dark';
  applyTheme(state.theme);
  localStorage.setItem(STORAGE_KEYS.theme, state.theme);
}

function applyTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  const toggle = document.getElementById('theme-toggle');
  const themeLabel = toggle?.querySelector('.theme-label');
  const themeIcon = toggle?.querySelector('.theme-icon');

  if (themeLabel) {
    themeLabel.textContent = theme === 'dark' ? 'Light' : 'Dark';
  }

  if (themeIcon) {
    themeIcon.textContent = theme === 'dark' ? '☀️' : '🌙';
  }
}

function updateSendButton() {
  const button = document.getElementById('send-button');
  if (!button) {
    return;
  }

  button.disabled = state.isProcessing;
  button.classList.toggle('is-loading', state.isProcessing);
}

function handleTextareaKeydown(event) {
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault();
    document.getElementById('chat-form').requestSubmit();
  }
}

function autoResizeTextarea() {
  const textarea = document.getElementById('prompt-input');
  if (!textarea) {
    return;
  }

  textarea.style.height = 'auto';
  textarea.style.height = `${Math.min(textarea.scrollHeight, 140)}px`;
}

function focusInput() {
  const input = document.getElementById('prompt-input');
  if (!state.isProcessing) {
    input?.focus();
  }
}

function createMessageId() {
  return `msg-${Date.now()}-${Math.random().toString(16).slice(2)}`;
}

function getAccentForUserMessage() {
  return state.messages.filter((message) => message.role === 'user').length % 4;
}

function getAccentGradient(index) {
  const gradients = [
    'linear-gradient(135deg, #2563eb 0%, #4f46e5 100%)',
    'linear-gradient(135deg, #14b8a6 0%, #0f766e 100%)',
    'linear-gradient(135deg, #9333ea 0%, #7c3aed 100%)',
    'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)',
  ];

  return gradients[index % gradients.length];
}

function formatTimestamp(isoTimestamp) {
  const timestamp = new Date(isoTimestamp);
  return timestamp.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
}

function escapeHtml(value) {
  return String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

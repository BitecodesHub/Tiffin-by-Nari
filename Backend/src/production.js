/**
 * Production entry point for Tiffins-by-Naari Backend.
 * Serves the React frontend static build alongside the Express API.
 * Used inside the Docker container so everything runs on a single port.
 */
require("dotenv").config({ override: false });
const path = require("path");
const express = require("express");
const app = require("./app");
const connectDB = require("./config/db");

const PORT = process.env.PORT || 5000;

// ── Serve frontend static assets ──────────────────────────────────
const frontendPath = path.join(__dirname, "../../Frontend/dist");
app.use(express.static(frontendPath));

// SPA catch-all: any non-API GET request falls through to index.html
app.use((req, res, next) => {
  if (req.method === "GET" && !req.path.startsWith("/api")) {
    return res.sendFile(path.join(frontendPath, "index.html"));
  }
  next();
});

// ── Start server ──────────────────────────────────────────────────
connectDB();

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Production server running on port ${PORT}`);
});

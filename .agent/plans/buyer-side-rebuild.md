# Buyer Side Rebuild - Implementation Plan

## Overview
Rebuild the buyer side of ProFabric (FabricFlow) with enhanced features:
- Order creation with sample image upload / AI design
- Budget & timeline setting with AI-powered textile manufacturer suggestions
- Textile selection & in-app communication
- Order status tracking with vendor progress updates
- Enhanced settings (profile, address, order history, help & support)
- Order reporting
- Common marketplace for all users

## Architecture
- **Framework**: Flutter (Dart)
- **State**: Riverpod
- **Theme**: Dark theme with AppTheme constants
- **Colors**: Primary #12AEE2, Background #101D22, Surface #1A2A30, Card #1E2D33, Accent #00C853
- **Routing**: AppRouter with named routes

## Work Streams (3 Parallel Agents)

### Agent 1: Order Flow (Create + AI + Budget + Vendor Matching)
- Enhanced CreateOrderScreen with image upload + AI design
- Budget & timeline configuration screen  
- AI-powered vendor matching/suggestion screen
- Order confirmation screen

### Agent 2: Dashboard + Tracking + Reporting
- Rebuilt BuyerDashboardScreen with bottom nav
- Order detail screen with vendor progress updates
- Order reporting screen
- Enhanced order tracking

### Agent 3: Settings + Marketplace + Chat
- Enhanced settings with profile, address, order history
- Common marketplace with product posting & buying
- Enhanced in-app chat between buyer and textile vendor

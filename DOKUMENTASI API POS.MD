markdown
# 📟 POS API Documentation

Versi: `v1`  
Format: `RESTful JSON`  
Auth: `Bearer Token`

---

## 🛍️ Product Management

### GET /pos/products

**Response:**

```json
[
  {
    "id": 1001,
    "name": "Kopi Luwak",
    "sku": "KLW-001",
    "price": 50000,
    "stock_level": 25
  },
  {
    "id": 1002,
    "name": "Teh Hijau",
    "sku": "THG-002",
    "price": 30000,
    "stock_level": 40
  }
]
GET /pos/products/:id
Response:

json
{
  "id": 1001,
  "name": "Kopi Luwak",
  "sku": "KLW-001",
  "description": "Kopi premium dengan cita rasa khas.",
  "price": 50000,
  "stock_level": 25,
  "created_at": "2025-08-05T07:30:00Z"
}
POST /pos/products
Request:

json
{
  "name": "Susu Kuda Liar",
  "sku": "SKL-003",
  "description": "Minuman khas dengan manfaat kesehatan.",
  "price": 45000,
  "initial_stock": 30
}
Response:

json
{
  "message": "Product created successfully",
  "id": 1003
}
PUT /pos/products/:id
Request:

json
{
  "price": 48000,
  "stock_level": 35
}
Response:

json
{
  "message": "Product updated successfully"
}
DELETE /pos/products/:id
Response:

json
{
  "message": "Product deleted successfully"
}
👥 Customer Management
GET /pos/customers
Response:

json
[
  {
    "id": 501,
    "name": "Andi",
    "email": "andi@example.com",
    "phone": "081234567890",
    "loyalty_points": 120
  },
  {
    "id": 502,
    "name": "Sari",
    "email": "sari@example.com",
    "phone": "089876543210",
    "loyalty_points": 80
  }
]
GET /pos/customers/:id
Response:

json
{
  "id": 501,
  "name": "Andi",
  "email": "andi@example.com",
  "phone": "081234567890",
  "loyalty_points": 120,
  "created_at": "2025-07-01T10:15:00Z"
}
POST /pos/customers
Request:

json
{
  "name": "Budi",
  "email": "budi@example.com",
  "phone": "085612345678",
  "loyalty_points": 0
}
Response:

json
{
  "message": "Customer created successfully",
  "id": 503
}
PUT /pos/customers/:id
Request:

json
{
  "phone": "085698765432",
  "loyalty_points": 50
}
Response:

json
{
  "message": "Customer updated successfully"
}
DELETE /pos/customers/:id
Response:

json
{
  "message": "Customer deleted successfully"
}
💰 Transactions
GET /pos/transactions
Response:

json
[
  {
    "id": 2001,
    "date": "2025-08-05T09:15:00Z",
    "total_amount": 150000,
    "status": "paid"
  },
  {
    "id": 2002,
    "date": "2025-08-05T09:45:00Z",
    "total_amount": 75000,
    "status": "pending"
  }
]
GET /pos/transactions/:id
Response:

json
{
  "id": 2001,
  "date": "2025-08-05T09:15:00Z",
  "customer_id": 501,
  "items": [
    {
      "product_id": 1001,
      "quantity": 2,
      "price": 50000
    },
    {
      "product_id": 1002,
      "quantity": 1,
      "price": 30000
    }
  ],
  "total_amount": 130000,
  "discount": 0,
  "status": "paid",
  "payments": [
    {
      "payment_id": 3001,
      "method": "cash",
      "amount": 130000
    }
  ]
}
POST /pos/transactions
Request:

json
{
  "customer_id": 502,
  "items": [
    { "product_id": 1003, "quantity": 1, "price": 45000 },
    { "product_id": 1002, "quantity": 2, "price": 30000 }
  ],
  "discount": 5000
}
Response:

json
{
  "message": "Transaction created successfully",
  "transaction_id": 2003
}
POST /pos/transactions/:id/payments
Request:

json
{
  "method": "credit_card",
  "amount": 85000
}
Response:

json
{
  "message": "Payment recorded successfully",
  "payment_id": 3002
}
POST /pos/transactions/:id/return
Request:

json
{
  "items": [
    { "product_id": 1002, "quantity": 1, "reason": "Damaged" }
  ]
}
Response:

json
{
  "message": "Return processed successfully",
  "return_id": 4001
}
🔄 Offline Sync
GET /pos/offline/sync
Response:

json
{
  "last_sync": "2025-08-05T08:00:00Z",
  "pending_records": 5
}
POST /pos/offline/sync
Request:

json
{
  "records": [
    {
      "type": "transaction",
      "data": {
        "transaction_id": 2004,
        "status": "pending",
        "items": [/* ... */]
      }
    },
    {
      "type": "product_update",
      "data": {
        "product_id": 1001,
        "stock_level": 28
      }
    }
  ]
}
Response:

json
{
  "message": "Offline records synced successfully",
  "synced_count": 2
}
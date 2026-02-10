export interface Order {
  id: string;
  storeName: string;
  customer: Customer;
  orderPayment: Payment;
  orderItems: OrderItem[];
  delivery: Delivery;
  meta: OrderMeta;
  totalOrderPrice: number;
  currency: { symbol: string; code: string };
  integrationOrderId: string;
  orderCardNumber: string;
}

export interface Customer {
  firstName: string;
  lastName: string;
  phone: string;
  email: string;
  address: string;
  addressDescription?: string;
  latitude?: number;
  longitude?: number;
}

export interface Payment {
  paymentType: string;
  ticketType: string|null;
  price: number;
  date: string|null;
}

export interface OrderItem {
  orderItemName: string;
  orderItemDescription: string;
  orderItemCount: number;
  orderItemPrice: string;
}

export interface Delivery {
  address: string;
  addressNote: string;
  latitude: number;
  longitude: number;
  distance?: number;
  duration?: number;
}

export interface OrderMeta {
  integrationOrderId: string;
  integrationType: string;
  platform: string;
  creationDate: string;
  clickingTime: string;
  warmthType: string;
  cookingTime: number;
  status: any; // Using any for now to hold raw status
  orderCardNumber: string;
}

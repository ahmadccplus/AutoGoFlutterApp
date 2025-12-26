import Stripe from 'stripe';
import { BookingModel } from '../models/Booking';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', {
  apiVersion: '2023-10-16',
});

export class PaymentService {
  static async createPaymentIntent(bookingId: number, amount: number): Promise<string> {
    const booking = await BookingModel.findById(bookingId);
    if (!booking) {
      throw new Error('Booking not found');
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Convert to cents
      currency: 'usd',
      metadata: {
        booking_id: bookingId.toString(),
      },
    });

    // Update booking with payment intent ID
    await BookingModel.update(bookingId, {
      payment_intent_id: paymentIntent.id,
    });

    return paymentIntent.client_secret || '';
  }

  static async confirmPayment(paymentIntentId: string): Promise<void> {
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    if (paymentIntent.status === 'succeeded') {
      const bookingId = parseInt(paymentIntent.metadata.booking_id);
      await BookingModel.update(bookingId, {
        payment_status: 'paid',
        status: 'active',
      });
    } else {
      throw new Error('Payment not completed');
    }
  }

  static async handleWebhook(payload: string, signature: string): Promise<void> {
    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
    if (!webhookSecret) {
      throw new Error('Webhook secret not configured');
    }

    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(payload, signature, webhookSecret);
    } catch (err: any) {
      throw new Error(`Webhook signature verification failed: ${err.message}`);
    }

    if (event.type === 'payment_intent.succeeded') {
      const paymentIntent = event.data.object as Stripe.PaymentIntent;
      const bookingId = parseInt(paymentIntent.metadata.booking_id);
      await BookingModel.update(bookingId, {
        payment_status: 'paid',
        status: 'active',
      });
    }
  }
}




import { Request, Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { PaymentService } from '../services/payment.service';

export class PaymentController {
  static async createPaymentIntent(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { booking_id, amount } = req.body;

      if (!booking_id || !amount) {
        res.status(400).json({
          success: false,
          message: 'Booking ID and amount are required',
        });
        return;
      }

      const clientSecret = await PaymentService.createPaymentIntent(
        booking_id,
        parseFloat(amount)
      );

      res.json({
        success: true,
        client_secret: clientSecret,
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to create payment intent',
      });
    }
  }

  static async confirmPayment(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { payment_intent_id } = req.body;

      if (!payment_intent_id) {
        res.status(400).json({
          success: false,
          message: 'Payment intent ID is required',
        });
        return;
      }

      await PaymentService.confirmPayment(payment_intent_id);

      res.json({
        success: true,
        message: 'Payment confirmed successfully',
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to confirm payment',
      });
    }
  }

  static async handleWebhook(req: Request, res: Response): Promise<void> {
    const sig = req.headers['stripe-signature'] as string;
    const payload = JSON.stringify(req.body);

    try {
      await PaymentService.handleWebhook(payload, sig);
      res.json({ received: true });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        message: error.message || 'Webhook handling failed',
      });
    }
  }

  static async payOnPickup(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { booking_id } = req.body;

      if (!booking_id) {
        res.status(400).json({
          success: false,
          message: 'Booking ID is required',
        });
        return;
      }

      // For demo: Just mark booking as pending payment
      // In production, you would update the booking status
      res.json({
        success: true,
        message: 'Booking confirmed. Payment will be collected on pickup.',
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to confirm pay on pickup',
      });
    }
  }
}




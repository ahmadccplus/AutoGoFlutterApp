import { Router } from 'express';
import { PaymentController } from '../controllers/payment.controller';
import { authenticateToken } from '../middleware/auth.middleware';
import express from 'express';

const router = Router();

router.post(
  '/intent',
  authenticateToken,
  PaymentController.createPaymentIntent
);
router.post('/confirm', authenticateToken, PaymentController.confirmPayment);
router.post('/pay-on-pickup', authenticateToken, PaymentController.payOnPickup);
router.post(
  '/webhook',
  express.raw({ type: 'application/json' }),
  PaymentController.handleWebhook
);

export default router;

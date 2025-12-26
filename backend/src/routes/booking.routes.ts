import { Router } from 'express';
import { BookingController } from '../controllers/booking.controller';
import { authenticateToken } from '../middleware/auth.middleware';

const router = Router();

router.post('/', authenticateToken, BookingController.createBooking);
router.get('/my', authenticateToken, BookingController.getMyBookings);
router.get('/:id', authenticateToken, BookingController.getBookingById);
router.put('/:id/sign', authenticateToken, BookingController.signContract);
router.delete('/:id', authenticateToken, BookingController.cancelBooking);

export default router;




import admin from 'firebase-admin';

// Initialize Firebase Admin
if (!admin.apps.length) {
  const serviceAccount = {
    projectId: process.env.FIREBASE_PROJECT_ID,
    privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
  };

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
  });
}

export class NotificationService {
  static async sendNotification(
    token: string,
    title: string,
    body: string,
    data?: { [key: string]: string }
  ): Promise<void> {
    const message = {
      notification: {
        title,
        body,
      },
      data: data || {},
      token,
    };

    try {
      await admin.messaging().send(message);
      console.log('Notification sent successfully');
    } catch (error) {
      console.error('Error sending notification:', error);
      throw error;
    }
  }

  static async sendToTopic(
    topic: string,
    title: string,
    body: string,
    data?: { [key: string]: string }
  ): Promise<void> {
    const message = {
      notification: {
        title,
        body,
      },
      data: data || {},
      topic,
    };

    try {
      await admin.messaging().send(message);
      console.log('Notification sent to topic successfully');
    } catch (error) {
      console.error('Error sending notification to topic:', error);
      throw error;
    }
  }

  static async sendBookingConfirmation(userToken: string, bookingId: number): Promise<void> {
    await this.sendNotification(
      userToken,
      'Booking Confirmed',
      'Your car rental booking has been confirmed!',
      { booking_id: bookingId.toString(), type: 'booking_confirmed' }
    );
  }

  static async sendPaymentSuccess(userToken: string, bookingId: number): Promise<void> {
    await this.sendNotification(
      userToken,
      'Payment Successful',
      'Your payment has been processed successfully.',
      { booking_id: bookingId.toString(), type: 'payment_success' }
    );
  }

  static async sendRentalRequest(hostToken: string, bookingId: number, renterName: string): Promise<void> {
    await this.sendNotification(
      hostToken,
      'New Rental Request',
      `You have a new rental request from ${renterName}`,
      { booking_id: bookingId.toString(), type: 'rental_request' }
    );
  }
}









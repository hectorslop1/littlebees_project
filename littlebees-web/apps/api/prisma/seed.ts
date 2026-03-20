import { PrismaClient } from '@prisma/client';
import * as argon2 from 'argon2';

const prisma = new PrismaClient();

function daysAgo(n: number): Date {
  const d = new Date();
  d.setDate(d.getDate() - n);
  d.setHours(0, 0, 0, 0);
  return d;
}

function randomTime(hourMin: number, hourMax: number): Date {
  const d = new Date();
  d.setHours(
    hourMin + Math.floor(Math.random() * (hourMax - hourMin)),
    Math.floor(Math.random() * 60),
    0,
    0,
  );
  return d;
}

async function main() {
  console.log('Seeding database...');

  // Clean existing data (using correct table names from schema)
  await prisma.$executeRaw`TRUNCATE TABLE "audit_logs" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "notifications" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "files" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "messages" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "conversation_participants" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "conversations" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "invoices" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "payments" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "extra_services" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "development_records" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "development_milestones" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "daily_log_entries" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "attendance_records" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "emergency_contacts" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "child_medical_info" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "child_parents" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "children" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "groups" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "refresh_tokens" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "user_tenants" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "users" CASCADE`;
  await prisma.$executeRaw`TRUNCATE TABLE "tenants" CASCADE`;

  // --- Tenant ---
  const tenant = await prisma.tenant.create({
    data: {
      name: 'Guardería Petit Soleil',
      slug: 'petit-soleil',
      email: 'admin@petitsoleil.mx',
      phone: '+52 55 1234 5678',
      address: 'Av. Reforma 123, Col. Centro, CDMX',
      timezone: 'America/Mexico_City',
      locale: 'es-MX',
      satRfc: 'GPS210101ABC',
      satRazonSocial: 'Guardería Petit Soleil S.A. de C.V.',
      subscriptionStatus: 'active',
      settings: {
        businessHours: { start: '07:00', end: '19:00' },
        maxChildrenPerGroup: 20,
      },
    },
  });

  console.log(`Created tenant: ${tenant.name} (${tenant.id})`);

  // --- Users ---
  const passwordHash = await argon2.hash('Password123!');

  const director = await prisma.user.create({
    data: {
      email: 'director@petitsoleil.mx',
      passwordHash,
      firstName: 'María',
      lastName: 'González',
      phone: '+52 55 9876 5432',
      emailVerified: true,
    },
  });

  const teacher = await prisma.user.create({
    data: {
      email: 'maestra@petitsoleil.mx',
      passwordHash,
      firstName: 'Ana',
      lastName: 'López',
      phone: '+52 55 1111 2222',
      emailVerified: true,
    },
  });

  const teacher2 = await prisma.user.create({
    data: {
      email: 'maestra2@petitsoleil.mx',
      passwordHash,
      firstName: 'Laura',
      lastName: 'Martínez',
      phone: '+52 55 1111 3333',
      emailVerified: true,
    },
  });

  const admin = await prisma.user.create({
    data: {
      email: 'admin@petitsoleil.mx',
      passwordHash,
      firstName: 'Roberto',
      lastName: 'Sánchez',
      phone: '+52 55 2222 3333',
      emailVerified: true,
    },
  });

  const parent1 = await prisma.user.create({
    data: {
      email: 'padre@gmail.com',
      passwordHash,
      firstName: 'Carlos',
      lastName: 'Ramírez',
      phone: '+52 55 3333 4444',
      emailVerified: true,
    },
  });

  const parent2 = await prisma.user.create({
    data: {
      email: 'madre@gmail.com',
      passwordHash,
      firstName: 'Patricia',
      lastName: 'López',
      phone: '+52 55 4444 5555',
      emailVerified: true,
    },
  });

  const parent3 = await prisma.user.create({
    data: {
      email: 'familia@gmail.com',
      passwordHash,
      firstName: 'Luis',
      lastName: 'García',
      phone: '+52 55 5555 6666',
      emailVerified: true,
    },
  });

  // Assign roles
  await prisma.userTenant.createMany({
    data: [
      { userId: director.id, tenantId: tenant.id, role: 'director' },
      { userId: teacher.id, tenantId: tenant.id, role: 'teacher' },
      { userId: teacher2.id, tenantId: tenant.id, role: 'teacher' },
      { userId: admin.id, tenantId: tenant.id, role: 'admin' },
      { userId: parent1.id, tenantId: tenant.id, role: 'parent' },
      { userId: parent2.id, tenantId: tenant.id, role: 'parent' },
      { userId: parent3.id, tenantId: tenant.id, role: 'parent' },
    ],
  });

  // --- Groups ---
  const lactantes = await prisma.group.create({
    data: {
      tenantId: tenant.id,
      name: 'Lactantes',
      ageRangeMin: 3,
      ageRangeMax: 12,
      capacity: 10,
      color: '#4ECDC4',
      academicYear: '2025-2026',
      teacherId: teacher.id,
    },
  });

  const maternal = await prisma.group.create({
    data: {
      tenantId: tenant.id,
      name: 'Maternal',
      ageRangeMin: 12,
      ageRangeMax: 24,
      capacity: 15,
      color: '#FF6B6B',
      academicYear: '2025-2026',
      teacherId: teacher.id,
    },
  });

  const preescolar1 = await prisma.group.create({
    data: {
      tenantId: tenant.id,
      name: 'Preescolar 1',
      ageRangeMin: 24,
      ageRangeMax: 36,
      capacity: 20,
      color: '#45B7D1',
      academicYear: '2025-2026',
      teacherId: teacher2.id,
    },
  });

  const preescolar2 = await prisma.group.create({
    data: {
      tenantId: tenant.id,
      name: 'Preescolar 2',
      ageRangeMin: 36,
      ageRangeMax: 48,
      capacity: 20,
      color: '#96CEB4',
      academicYear: '2025-2026',
      teacherId: teacher2.id,
    },
  });

  // --- Children ---
  const sofia = await prisma.child.create({
    data: {
      tenantId: tenant.id,
      firstName: 'Sofía',
      lastName: 'Ramírez',
      dateOfBirth: new Date('2024-03-15'),
      gender: 'female',
      groupId: lactantes.id,
      enrollmentDate: new Date('2025-01-15'),
      status: 'active',
    },
  });

  const diego = await prisma.child.create({
    data: {
      tenantId: tenant.id,
      firstName: 'Diego',
      lastName: 'Hernández',
      dateOfBirth: new Date('2023-08-20'),
      gender: 'male',
      groupId: maternal.id,
      enrollmentDate: new Date('2025-02-01'),
      status: 'active',
    },
  });

  const valentina = await prisma.child.create({
    data: {
      tenantId: tenant.id,
      firstName: 'Valentina',
      lastName: 'García',
      dateOfBirth: new Date('2024-06-10'),
      gender: 'female',
      groupId: lactantes.id,
      enrollmentDate: new Date('2025-03-01'),
      status: 'active',
    },
  });

  const mateo = await prisma.child.create({
    data: {
      tenantId: tenant.id,
      firstName: 'Mateo',
      lastName: 'López',
      dateOfBirth: new Date('2023-11-05'),
      gender: 'male',
      groupId: maternal.id,
      enrollmentDate: new Date('2025-01-20'),
      status: 'active',
    },
  });

  const isabella = await prisma.child.create({
    data: {
      tenantId: tenant.id,
      firstName: 'Isabella',
      lastName: 'Sánchez',
      dateOfBirth: new Date('2023-02-14'),
      gender: 'female',
      groupId: preescolar1.id,
      enrollmentDate: new Date('2025-01-10'),
      status: 'active',
    },
  });

  const santiago = await prisma.child.create({
    data: {
      tenantId: tenant.id,
      firstName: 'Santiago',
      lastName: 'Ramírez',
      dateOfBirth: new Date('2022-07-22'),
      gender: 'male',
      groupId: preescolar2.id,
      enrollmentDate: new Date('2025-02-15'),
      status: 'active',
    },
  });

  const allChildren = [sofia, diego, valentina, mateo, isabella, santiago];

  // --- Parent-Child links ---
  await prisma.childParent.createMany({
    data: [
      { childId: sofia.id, userId: parent1.id, relationship: 'padre', isPrimary: true, canPickup: true },
      { childId: santiago.id, userId: parent1.id, relationship: 'padre', isPrimary: true, canPickup: true },
      { childId: diego.id, userId: parent2.id, relationship: 'madre', isPrimary: true, canPickup: true },
      { childId: mateo.id, userId: parent2.id, relationship: 'madre', isPrimary: true, canPickup: true },
      { childId: valentina.id, userId: parent3.id, relationship: 'padre', isPrimary: true, canPickup: true },
      { childId: isabella.id, userId: parent3.id, relationship: 'padre', isPrimary: true, canPickup: true },
    ],
  });

  // --- Medical Info ---
  await prisma.childMedicalInfo.createMany({
    data: [
      {
        tenantId: tenant.id,
        childId: sofia.id,
        allergies: ['Nueces'],
        conditions: [],
        medications: [],
        bloodType: 'O+',
        doctorName: 'Dr. Pérez',
        doctorPhone: '+52 55 5555 6666',
      },
      {
        tenantId: tenant.id,
        childId: diego.id,
        allergies: [],
        conditions: ['Asma leve'],
        medications: ['Salbutamol (en caso de crisis)'],
        bloodType: 'A+',
        doctorName: 'Dra. Rodríguez',
        doctorPhone: '+52 55 7777 8888',
      },
      {
        tenantId: tenant.id,
        childId: valentina.id,
        allergies: ['Leche de vaca'],
        conditions: [],
        medications: [],
        bloodType: 'B+',
        doctorName: 'Dr. Méndez',
        doctorPhone: '+52 55 9999 0000',
      },
      {
        tenantId: tenant.id,
        childId: isabella.id,
        allergies: [],
        conditions: [],
        medications: [],
        bloodType: 'O-',
        doctorName: 'Dra. Torres',
        doctorPhone: '+52 55 1234 0000',
      },
    ],
  });

  // --- Emergency Contacts ---
  await prisma.emergencyContact.createMany({
    data: [
      { tenantId: tenant.id, childId: sofia.id, name: 'Abuela Rosa', relationship: 'abuela', phone: '+52 55 1000 2000', priority: 1 },
      { tenantId: tenant.id, childId: sofia.id, name: 'Tío Jorge', relationship: 'tío', phone: '+52 55 1000 3000', priority: 2 },
      { tenantId: tenant.id, childId: diego.id, name: 'Abuela María', relationship: 'abuela', phone: '+52 55 2000 3000', priority: 1 },
      { tenantId: tenant.id, childId: valentina.id, name: 'Tía Carmen', relationship: 'tía', phone: '+52 55 3000 4000', priority: 1 },
      { tenantId: tenant.id, childId: isabella.id, name: 'Abuelo Pedro', relationship: 'abuelo', phone: '+52 55 4000 5000', priority: 1 },
      { tenantId: tenant.id, childId: santiago.id, name: 'Abuela Rosa', relationship: 'abuela', phone: '+52 55 1000 2000', priority: 1 },
    ],
  });

  // --- Development Milestones ---
  const milestoneData = [
    { category: 'motor_gross' as const, title: 'Se sienta sin apoyo', ageRangeMin: 6, ageRangeMax: 9, sortOrder: 1 },
    { category: 'motor_gross' as const, title: 'Gatea', ageRangeMin: 7, ageRangeMax: 10, sortOrder: 2 },
    { category: 'motor_gross' as const, title: 'Camina con apoyo', ageRangeMin: 9, ageRangeMax: 12, sortOrder: 3 },
    { category: 'motor_gross' as const, title: 'Camina solo', ageRangeMin: 12, ageRangeMax: 18, sortOrder: 4 },
    { category: 'motor_fine' as const, title: 'Agarra objetos con pinza', ageRangeMin: 8, ageRangeMax: 12, sortOrder: 1 },
    { category: 'motor_fine' as const, title: 'Apila 2-3 bloques', ageRangeMin: 12, ageRangeMax: 18, sortOrder: 2 },
    { category: 'cognitive' as const, title: 'Busca objetos escondidos', ageRangeMin: 8, ageRangeMax: 12, sortOrder: 1 },
    { category: 'cognitive' as const, title: 'Identifica colores básicos', ageRangeMin: 24, ageRangeMax: 36, sortOrder: 2 },
    { category: 'language' as const, title: 'Dice mamá/papá', ageRangeMin: 10, ageRangeMax: 14, sortOrder: 1 },
    { category: 'language' as const, title: 'Forma oraciones de 2 palabras', ageRangeMin: 18, ageRangeMax: 24, sortOrder: 2 },
    { category: 'social' as const, title: 'Sonríe a personas conocidas', ageRangeMin: 2, ageRangeMax: 6, sortOrder: 1 },
    { category: 'social' as const, title: 'Juega junto a otros niños', ageRangeMin: 18, ageRangeMax: 30, sortOrder: 2 },
    { category: 'emotional' as const, title: 'Muestra preferencia por cuidadores', ageRangeMin: 6, ageRangeMax: 10, sortOrder: 1 },
    { category: 'emotional' as const, title: 'Expresa emociones básicas', ageRangeMin: 12, ageRangeMax: 24, sortOrder: 2 },
  ];

  const milestones = [];
  for (const m of milestoneData) {
    const milestone = await prisma.developmentMilestone.create({
      data: { ...m, description: `Hito de desarrollo: ${m.title}` },
    });
    milestones.push(milestone);
  }

  // --- Attendance Records (past 2 weeks, weekdays only) ---
  const statuses = ['present', 'present', 'present', 'present', 'absent', 'late', 'excused'] as const;

  for (let day = 1; day <= 14; day++) {
    const date = daysAgo(day);
    if (date.getDay() === 0 || date.getDay() === 6) continue; // skip weekends

    for (const child of allChildren) {
      const status = statuses[Math.floor(Math.random() * statuses.length)];
      const checkInTime = new Date(date);
      checkInTime.setHours(7 + Math.floor(Math.random() * 2), Math.floor(Math.random() * 60));

      const checkOutTime = new Date(date);
      checkOutTime.setHours(14 + Math.floor(Math.random() * 4), Math.floor(Math.random() * 60));

      await prisma.attendanceRecord.create({
        data: {
          tenantId: tenant.id,
          childId: child.id,
          date,
          status,
          checkInAt: status !== 'absent' ? checkInTime : null,
          checkOutAt: status === 'present' || status === 'late' ? checkOutTime : null,
          checkInBy: status !== 'absent' ? teacher.id : null,
          checkOutBy: status === 'present' || status === 'late' ? teacher.id : null,
          checkInMethod: status !== 'absent' ? 'manual' : null,
        },
      });
    }
  }

  // --- Daily Log Entries (past 5 days) ---
  const logTypes = ['meal', 'nap', 'activity', 'observation'] as const;
  const mealMetadata = [
    { food: 'Papilla de frutas', quantity: '80%', notes: 'Comió bien' },
    { food: 'Puré de verduras', quantity: '60%', notes: 'No le gustó mucho' },
    { food: 'Cereal con leche', quantity: '100%', notes: 'Excelente apetito' },
  ];
  const napMetadata = [
    { startTime: '12:00', endTime: '13:30', quality: 'buena' },
    { startTime: '12:30', endTime: '14:00', quality: 'excelente' },
    { startTime: '11:45', endTime: '12:45', quality: 'regular' },
  ];

  for (let day = 0; day < 5; day++) {
    const date = daysAgo(day);
    if (date.getDay() === 0 || date.getDay() === 6) continue;

    for (const child of allChildren.slice(0, 4)) {
      // Meal log
      await prisma.dailyLogEntry.create({
        data: {
          tenantId: tenant.id,
          childId: child.id,
          date,
          type: 'meal',
          title: 'Desayuno',
          description: 'Desayuno de la mañana',
          time: '09:00',
          metadata: mealMetadata[Math.floor(Math.random() * mealMetadata.length)],
          recordedBy: teacher.id,
        },
      });

      // Nap log
      await prisma.dailyLogEntry.create({
        data: {
          tenantId: tenant.id,
          childId: child.id,
          date,
          type: 'nap',
          title: 'Siesta',
          description: 'Siesta después de la comida',
          time: '12:00',
          metadata: napMetadata[Math.floor(Math.random() * napMetadata.length)],
          recordedBy: teacher.id,
        },
      });

      // Activity log
      await prisma.dailyLogEntry.create({
        data: {
          tenantId: tenant.id,
          childId: child.id,
          date,
          type: 'activity',
          title: 'Estimulación temprana',
          description: 'Actividades de motricidad fina con bloques',
          time: '10:30',
          metadata: { duration: '30 min', materials: ['Bloques', 'Pelotas'] },
          recordedBy: teacher.id,
        },
      });
    }
  }

  // --- Development Records ---
  const devStatuses = ['achieved', 'in_progress', 'not_achieved'] as const;

  for (const child of [sofia, diego, valentina, mateo]) {
    const relevantMilestones = milestones.slice(0, 6);
    for (const milestone of relevantMilestones) {
      await prisma.developmentRecord.create({
        data: {
          tenantId: tenant.id,
          childId: child.id,
          milestoneId: milestone.id,
          status: devStatuses[Math.floor(Math.random() * devStatuses.length)],
          observations: 'Evaluación realizada durante actividades regulares',
          evaluatedBy: teacher.id,
          evaluatedAt: daysAgo(Math.floor(Math.random() * 30)),
          evidenceUrls: [],
        },
      });
    }
  }

  // --- Conversations & Messages ---
  const conv1 = await prisma.conversation.create({
    data: {
      tenantId: tenant.id,
      childId: sofia.id,
      participants: {
        create: [
          { userId: parent1.id, joinedAt: new Date() },
          { userId: teacher.id, joinedAt: new Date() },
        ],
      },
    },
  });

  const conv1Messages = [
    { senderId: parent1.id, content: 'Buenos días maestra, ¿cómo amaneció Sofía hoy?', messageType: 'text' },
    { senderId: teacher.id, content: 'Buenos días Don Carlos, Sofía llegó muy contenta hoy. Ya está desayunando.', messageType: 'text' },
    { senderId: parent1.id, content: 'Qué bueno, ayer no cenó mucho y me preocupaba.', messageType: 'text' },
    { senderId: teacher.id, content: 'No se preocupe, hoy desayunó todo su plato. Le encantó la papilla de manzana.', messageType: 'text' },
    { senderId: parent1.id, content: '¡Excelente! Muchas gracias por avisarme.', messageType: 'text' },
    { senderId: teacher.id, content: 'Con gusto. Le envío fotos de su actividad más tarde.', messageType: 'text' },
    { senderId: parent1.id, content: 'Perfecto, gracias maestra Ana. 🙏', messageType: 'text' },
  ];

  for (let i = 0; i < conv1Messages.length; i++) {
    const createdAt = new Date();
    createdAt.setMinutes(createdAt.getMinutes() - (conv1Messages.length - i) * 5);
    await prisma.message.create({
      data: {
        tenantId: tenant.id,
        conversationId: conv1.id,
        ...conv1Messages[i],
        createdAt,
      },
    });
  }

  const conv2 = await prisma.conversation.create({
    data: {
      tenantId: tenant.id,
      childId: diego.id,
      participants: {
        create: [
          { userId: parent2.id, joinedAt: new Date() },
          { userId: teacher.id, joinedAt: new Date() },
        ],
      },
    },
  });

  const conv2Messages = [
    { senderId: teacher.id, content: 'Buenas tardes, le informo que Diego tuvo un excelente día.', messageType: 'text' },
    { senderId: teacher.id, content: 'Hoy participó mucho en la actividad de estimulación temprana.', messageType: 'text' },
    { senderId: parent2.id, content: 'Qué alegría escuchar eso. ¿Cómo le fue con la siesta?', messageType: 'text' },
    { senderId: teacher.id, content: 'Durmió casi 2 horas, muy tranquilo.', messageType: 'text' },
    { senderId: parent2.id, content: 'Perfecto. Paso por él a las 5:30pm.', messageType: 'text' },
  ];

  for (let i = 0; i < conv2Messages.length; i++) {
    const createdAt = new Date();
    createdAt.setHours(createdAt.getHours() - 2);
    createdAt.setMinutes(createdAt.getMinutes() - (conv2Messages.length - i) * 3);
    await prisma.message.create({
      data: {
        tenantId: tenant.id,
        conversationId: conv2.id,
        ...conv2Messages[i],
        createdAt,
      },
    });
  }

  // --- Payments (past 3 months) ---
  const months = ['Enero', 'Febrero', 'Marzo'];
  const monthDates = [
    { due: new Date('2026-01-05'), paid: new Date('2026-01-04') },
    { due: new Date('2026-02-05'), paid: new Date('2026-02-03') },
    { due: new Date('2026-03-05'), paid: null },
  ];

  const paidPaymentIds: string[] = [];

  for (const child of allChildren) {
    for (let m = 0; m < months.length; m++) {
      const isPaid = m < 2;
      const isOverdue = m === 2 && Math.random() < 0.3;

      const payment = await prisma.payment.create({
        data: {
          tenantId: tenant.id,
          childId: child.id,
          concept: `Colegiatura ${months[m]} 2026`,
          amount: 4500 + Math.floor(Math.random() * 3000),
          currency: 'MXN',
          status: isPaid ? 'paid' : isOverdue ? 'overdue' : 'pending',
          dueDate: monthDates[m].due,
          paidAt: isPaid ? monthDates[m].paid : null,
          paymentMethod: isPaid ? 'spei' : null,
        },
      });

      if (isPaid) paidPaymentIds.push(payment.id);
    }
  }

  // --- Invoices ---
  for (const paymentId of paidPaymentIds.slice(0, 4)) {
    await prisma.invoice.create({
      data: {
        tenantId: tenant.id,
        paymentId,
        folio: `KS-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
        rfcEmisor: tenant.satRfc || '',
        rfcReceptor: 'XAXX010101000',
        total: 4500,
        status: 'valid',
        issuedAt: new Date(),
      },
    });
  }

  // --- Extra Services ---
  await prisma.extraService.createMany({
    data: [
      {
        tenantId: tenant.id,
        name: 'Clase de Inglés',
        description: 'Clases de inglés con metodología lúdica para niños de 2 a 5 años',
        type: 'class',
        schedule: 'Lunes y Miércoles 10:00-11:00',
        price: 800,
        capacity: 15,
        status: 'active',
      },
      {
        tenantId: tenant.id,
        name: 'Clase de Música',
        description: 'Iniciación musical con instrumentos de percusión',
        type: 'class',
        schedule: 'Martes y Jueves 11:00-12:00',
        price: 750,
        capacity: 12,
        status: 'active',
      },
      {
        tenantId: tenant.id,
        name: 'Taller de Arte',
        description: 'Taller de expresión artística con pintura y manualidades',
        type: 'workshop',
        schedule: 'Viernes 10:00-12:00',
        price: 600,
        capacity: 10,
        status: 'active',
      },
      {
        tenantId: tenant.id,
        name: 'Kit de Útiles Escolares',
        description: 'Kit completo de útiles para el ciclo escolar',
        type: 'marketplace_item',
        price: 350,
        status: 'active',
      },
    ],
  });

  // --- Notifications ---
  await prisma.notification.createMany({
    data: [
      {
        tenantId: tenant.id,
        userId: parent1.id,
        type: 'attendance_alert',
        title: 'Sofía registró su entrada',
        body: 'Sofía fue registrada a las 8:15 AM',
        data: { childId: sofia.id },
        read: true,
        readAt: daysAgo(0),
        sentAt: daysAgo(0),
        channel: 'in_app',
      },
      {
        tenantId: tenant.id,
        userId: parent1.id,
        type: 'payment_due',
        title: 'Pago próximo a vencer',
        body: 'La colegiatura de Marzo 2026 vence el 5 de marzo',
        data: { concept: 'Colegiatura Marzo 2026' },
        read: false,
        sentAt: daysAgo(1),
        channel: 'in_app',
      },
      {
        tenantId: tenant.id,
        userId: parent1.id,
        type: 'new_message',
        title: 'Nuevo mensaje de Maestra Ana',
        body: 'Le envío fotos de su actividad más tarde.',
        data: { conversationId: conv1.id },
        read: false,
        sentAt: daysAgo(0),
        channel: 'in_app',
      },
      {
        tenantId: tenant.id,
        userId: parent2.id,
        type: 'development_update',
        title: 'Nueva evaluación de desarrollo',
        body: 'Diego fue evaluado en el área de motricidad gruesa',
        data: { childId: diego.id },
        read: true,
        readAt: daysAgo(2),
        sentAt: daysAgo(3),
        channel: 'in_app',
      },
      {
        tenantId: tenant.id,
        userId: director.id,
        type: 'payment_overdue',
        title: 'Pagos vencidos',
        body: 'Hay 2 pagos vencidos que requieren atención',
        data: {},
        read: false,
        sentAt: daysAgo(0),
        channel: 'in_app',
      },
      {
        tenantId: tenant.id,
        userId: parent3.id,
        type: 'attendance_alert',
        title: 'Valentina registró su entrada',
        body: 'Valentina fue registrada a las 7:50 AM',
        data: { childId: valentina.id },
        read: true,
        readAt: daysAgo(0),
        sentAt: daysAgo(0),
        channel: 'in_app',
      },
    ],
  });

  // --- Day Schedule Template ---
  await prisma.dayScheduleTemplate.create({
    data: {
      tenantId: tenant.id,
      name: 'Horario Estándar',
      isDefault: true,
      items: [
        { time: '07:30', type: 'check_in', label: 'Entrada' },
        { time: '09:00', type: 'activity', label: 'Actividad educativa' },
        { time: '10:00', type: 'other', label: 'Recreo' },
        { time: '11:00', type: 'meal', label: 'Comida' },
        { time: '12:00', type: 'nap', label: 'Siesta' },
        { time: '14:00', type: 'activity', label: 'Actividad libre' },
        { time: '16:00', type: 'check_out', label: 'Salida' },
      ],
    },
  });

  console.log('Seed completed!');
  console.log('---');
  console.log('Demo credentials (Password: Password123!):');
  console.log('  Director: director@petitsoleil.mx');
  console.log('  Admin:    admin@petitsoleil.mx');
  console.log('  Maestra:  maestra@petitsoleil.mx');
  console.log('  Maestra2: maestra2@petitsoleil.mx');
  console.log('  Padre:    padre@gmail.com');
  console.log('  Madre:    madre@gmail.com');
  console.log('  Familia:  familia@gmail.com');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

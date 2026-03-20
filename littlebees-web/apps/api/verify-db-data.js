const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function verifyData() {
  try {
    const today = new Date().toISOString().split('T')[0];
    console.log('=== VERIFICACIÓN DE DATOS EN BASE DE DATOS ===\n');
    console.log('📅 Fecha de hoy:', today, '\n');

    // 1. Verificar registros de asistencia
    console.log('--- 1. REGISTROS DE ASISTENCIA ---');
    const attendance = await prisma.attendance.findMany({
      where: {
        date: {
          gte: new Date(today)
        }
      },
      include: {
        child: {
          select: {
            firstName: true,
            lastName: true
          }
        }
      },
      take: 10
    });
    
    console.log('📊 Total de registros de asistencia (hoy):', attendance.length);
    if (attendance.length > 0) {
      attendance.forEach(a => {
        console.log(`  - ${a.child.firstName} ${a.child.lastName} | ${a.status} | Check-in: ${a.checkInAt || 'N/A'}`);
      });
    } else {
      console.log('  ⚠️  No hay registros de asistencia para hoy');
      
      // Verificar si hay registros antiguos
      const oldAttendance = await prisma.attendance.findMany({
        take: 5,
        orderBy: { date: 'desc' },
        include: {
          child: {
            select: {
              firstName: true,
              lastName: true
            }
          }
        }
      });
      
      if (oldAttendance.length > 0) {
        console.log('\n  📌 Últimos registros de asistencia (cualquier fecha):');
        oldAttendance.forEach(a => {
          console.log(`     - ${a.child.firstName} ${a.child.lastName} | ${a.date.toISOString().split('T')[0]} | ${a.status}`);
        });
      }
    }

    // 2. Verificar daily logs
    console.log('\n--- 2. DAILY LOGS ---');
    const dailyLogs = await prisma.dailyLog.findMany({
      where: {
        date: {
          gte: new Date(today)
        }
      },
      include: {
        child: {
          select: {
            firstName: true,
            lastName: true
          }
        }
      },
      take: 10
    });
    
    console.log('📝 Total de daily logs (hoy):', dailyLogs.length);
    if (dailyLogs.length > 0) {
      dailyLogs.forEach(l => {
        const notes = l.notes ? l.notes.substring(0, 50) + '...' : 'Sin notas';
        console.log(`  - ${l.child.firstName} ${l.child.lastName} | ${l.activityType} | ${notes}`);
      });
    } else {
      console.log('  ⚠️  No hay daily logs para hoy');
      
      // Verificar si hay logs antiguos
      const oldLogs = await prisma.dailyLog.findMany({
        take: 5,
        orderBy: { date: 'desc' },
        include: {
          child: {
            select: {
              firstName: true,
              lastName: true
            }
          }
        }
      });
      
      if (oldLogs.length > 0) {
        console.log('\n  📌 Últimos daily logs (cualquier fecha):');
        oldLogs.forEach(l => {
          console.log(`     - ${l.child.firstName} ${l.child.lastName} | ${l.date.toISOString().split('T')[0]} | ${l.activityType}`);
        });
      }
    }

    // 3. Verificar conversaciones
    console.log('\n--- 3. CONVERSACIONES Y MENSAJES ---');
    const conversations = await prisma.conversation.findMany({
      take: 10,
      include: {
        _count: {
          select: {
            messages: true
          }
        },
        participants: {
          include: {
            user: {
              select: {
                firstName: true,
                lastName: true,
                role: true
              }
            }
          }
        }
      }
    });
    
    console.log('💬 Total de conversaciones:', conversations.length);
    if (conversations.length > 0) {
      for (const conv of conversations) {
        const participants = conv.participants.map(p => 
          `${p.user.firstName} ${p.user.lastName} (${p.user.role})`
        ).join(', ');
        console.log(`  - ID: ${conv.id.substring(0, 8)}... | Mensajes: ${conv._count.messages} | Participantes: ${participants}`);
        
        // Mostrar algunos mensajes
        if (conv._count.messages > 0) {
          const messages = await prisma.message.findMany({
            where: { conversationId: conv.id },
            take: 3,
            orderBy: { createdAt: 'desc' },
            include: {
              sender: {
                select: {
                  firstName: true,
                  lastName: true
                }
              }
            }
          });
          
          messages.forEach(m => {
            const preview = m.content.substring(0, 40) + (m.content.length > 40 ? '...' : '');
            console.log(`     └─ ${m.sender.firstName}: "${preview}"`);
          });
        }
      }
    } else {
      console.log('  ⚠️  No hay conversaciones en la base de datos');
    }

    // 4. Verificar niños y grupos
    console.log('\n--- 4. NIÑOS Y GRUPOS ---');
    const children = await prisma.child.findMany({
      where: {
        status: 'active'
      },
      include: {
        group: {
          select: {
            name: true,
            friendlyName: true
          }
        }
      },
      take: 10
    });
    
    console.log('👶 Total de niños activos:', children.length);
    if (children.length > 0) {
      children.forEach(c => {
        const groupName = c.group ? (c.group.friendlyName || c.group.name) : 'Sin grupo';
        console.log(`  - ${c.firstName} ${c.lastName} | Grupo: ${groupName}`);
      });
    }

    console.log('\n=== FIN DE VERIFICACIÓN ===\n');

  } catch (error) {
    console.error('❌ Error al verificar datos:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

verifyData();

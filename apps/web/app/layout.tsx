import Link from 'next/link';
import { LayoutDashboard, Users, Upload, FileText, Settings, Menu } from 'lucide-react';
import './globals.css';

export const metadata = {
  title: 'Military Attendance System',
  description: 'Admin Dashboard for Military Attendance System',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <div className="flex min-h-screen bg-gray-50">
          {/* Sidebar */}
          <aside className="sidebar">
            <div className="sidebar-brand">
              <div className="sidebar-brand-icon">⚔️</div>
              <div className="sidebar-brand-text">MAS</div>
            </div>

            <nav className="sidebar-nav">
              <NavLink href="/dashboard" icon={<LayoutDashboard className="nav-icon" />}>
                Dashboard
              </NavLink>
              <NavLink href="/members" icon={<Users className="nav-icon" />}>
                Members
              </NavLink>
              <NavLink href="/import" icon={<Upload className="nav-icon" />}>
                Bulk Import
              </NavLink>
              <NavLink href="/logs" icon={<FileText className="nav-icon" />}>
                Activity Logs
              </NavLink>
              <NavLink href="/settings" icon={<Settings className="nav-icon" />}>
                Settings
              </NavLink>
            </nav>

            <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-slate-700 text-xs text-gray-400">
              <div>Military Attendance v1.0</div>
              <div>© 2026 Defense Ministry</div>
            </div>
          </aside>

          {/* Main Content */}
          <main className="main-content flex-1">
            {children}
          </main>
        </div>
      </body>
    </html>
  );
}

function NavLink({
  href,
  children,
  icon,
}: {
  href: string;
  children: string;
  icon: React.ReactNode;
}) {
  return (
    <Link
      href={href}
      className="nav-item group"
    >
      {icon}
      <span className="group-hover:translate-x-0.5 transition-transform">{children}</span>
    </Link>
  );
}

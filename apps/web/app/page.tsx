import Link from 'next/link';
import { Shield, Zap, Lock, BarChart3 } from 'lucide-react';

export default function Page() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-600 via-blue-700 to-slate-900 flex flex-col items-center justify-center px-4">
      <div className="max-w-2xl mx-auto text-center text-white">
        {/* Logo Section */}
        <div className="mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-white/10 backdrop-blur-md rounded-2xl border border-white/20 mb-6">
            <Shield className="w-8 h-8" />
          </div>
          <h1 className="text-5xl md:text-6xl font-bold mb-4 tracking-tight">Military Attendance System</h1>
          <p className="text-xl text-blue-100 mb-8">Enterprise-grade QR-based attendance tracking with real-time monitoring</p>
        </div>

        {/* Features Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-12">
          <FeatureCard
            icon={<Zap className="w-6 h-6" />}
            title="Real-time Tracking"
            description="Live updates and instant notifications"
          />
          <FeatureCard
            icon={<Lock className="w-6 h-6" />}
            title="High Security"
            description="Advanced anomaly detection & validation"
          />
          <FeatureCard
            icon={<BarChart3 className="w-6 h-6" />}
            title="Analytics"
            description="Comprehensive statistics & reports"
          />
          <FeatureCard
            icon={<Shield className="w-6 h-6" />}
            title="Audit Trail"
            description="Complete activity logging"
          />
        </div>

        {/* CTA Button */}
        <Link
          href="/dashboard"
          className="inline-flex items-center gap-2 bg-white text-blue-700 px-8 py-4 rounded-xl font-semibold hover:bg-blue-50 transition-all duration-200 shadow-xl hover:shadow-2xl hover:scale-105"
        >
          Access Dashboard
          <span>→</span>
        </Link>

        {/* Info Footer */}
        <div className="mt-16 pt-8 border-t border-white/10">
          <p className="text-sm text-blue-100">Secure Military Operations Management</p>
          <p className="text-xs text-blue-200 mt-2">© 2026 Defense Ministry - Classified</p>
        </div>
      </div>
    </div>
  );
}

function FeatureCard({
  icon,
  title,
  description,
}: {
  icon: React.ReactNode;
  title: string;
  description: string;
}) {
  return (
    <div className="bg-white/10 backdrop-blur-md border border-white/20 rounded-xl p-6 hover:bg-white/20 transition-all duration-200">
      <div className="flex items-center gap-4">
        <div className="text-blue-200">{icon}</div>
        <div className="text-left">
          <h3 className="font-semibold text-white mb-1">{title}</h3>
          <p className="text-sm text-blue-100">{description}</p>
        </div>
      </div>
    </div>
  );
}

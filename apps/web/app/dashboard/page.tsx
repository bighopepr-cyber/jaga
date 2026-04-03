'use client';

import { useEffect, useState } from 'react';
import axios from 'axios';
import { Users, CheckCircle, XCircle, Clock, AlertTriangle, RefreshCw } from 'lucide-react';
import type { IAttendanceStats } from '@mas/types';

export default function DashboardPage() {
  const [stats, setStats] = useState<IAttendanceStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const response = await axios.get(
          `${process.env.NEXT_PUBLIC_API_URL}/stats/attendance`,
        );
        setStats(response.data);
        setError(null);
      } catch (error) {
        console.error('Failed to fetch stats:', error);
        setError('Failed to load dashboard stats. Please try again later.');
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  if (loading) {
    return (
      <div className="page-header mb-8">
        <div className="px-8 py-6">
          <div className="flex items-center justify-center h-64">
            <div className="text-center">
              <RefreshCw className="w-12 h-12 text-blue-600 animate-spin mx-auto mb-4" />
              <p className="text-gray-600">Loading dashboard...</p>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="page-header mb-8">
        <div className="px-8 py-6">
          <div className="alert alert-danger">
            <AlertTriangle className="w-5 h-5 inline-block mr-2" />
            {error}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Page Header */}
      <div className="page-header">
        <div className="px-8 py-6">
          <div className="page-title">Dashboard</div>
          <p className="page-description">Real-time attendance monitoring and system status</p>
        </div>
      </div>

      {/* Main Content */}
      <div className="px-8 pb-8">
        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <StatCard
            icon={Users}
            title="Total Members"
            value={stats?.totalMembers || 0}
            color="blue"
            description="Active personnel"
          />
          <StatCard
            icon={CheckCircle}
            title="Present"
            value={stats?.presentCount || 0}
            color="green"
            description="Marked attendance"
          />
          <StatCard
            icon={XCircle}
            title="Absent"
            value={stats?.absentCount || 0}
            color="red"
            description="Not present"
          />
          <StatCard
            icon={Clock}
            title="Late"
            value={stats?.lateCount || 0}
            color="yellow"
            description="Arrived late"
          />
        </div>

        {/* Security Alerts */}
        <div className="card">
          <div className="card-header bg-red-50 border-b border-red-200">
            <AlertTriangle className="w-5 h-5 text-red-600 inline-block mr-2" />
            <span className="text-lg font-semibold text-red-900">Security Alerts</span>
          </div>
          <div className="card-body">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
                  <AlertTriangle className="w-6 h-6 text-orange-600" />
                </div>
                <div>
                  <p className="text-sm text-gray-600">Suspicious Activity</p>
                  <p className="text-2xl font-bold">{stats?.suspiciousCount || 0}</p>
                </div>
              </div>
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-red-100 rounded-lg flex items-center justify-center">
                  <XCircle className="w-6 h-6 text-red-600" />
                </div>
                <div>
                  <p className="text-sm text-gray-600">Blocked Access</p>
                  <p className="text-2xl font-bold">{stats?.blockedCount || 0}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function StatCard({
  icon: Icon,
  title,
  value,
  color,
  description,
}: {
  icon: React.ComponentType<{ className: string }>;
  title: string;
  value: number;
  color: string;
  description: string;
}) {
  const colorClasses: Record<string, { bg: string; border: string; icon: string; text: string }> = {
    blue: { bg: 'bg-blue-50', border: 'border-blue-200', icon: 'text-blue-600', text: 'text-blue-700' },
    green: { bg: 'bg-green-50', border: 'border-green-200', icon: 'text-green-600', text: 'text-green-700' },
    red: { bg: 'bg-red-50', border: 'border-red-200', icon: 'text-red-600', text: 'text-red-700' },
    yellow: { bg: 'bg-yellow-50', border: 'border-yellow-200', icon: 'text-yellow-600', text: 'text-yellow-700' },
  };

  const classes = colorClasses[color] || colorClasses.blue;

  return (
    <div className={`stat-card ${classes.bg} border ${classes.border}`}>
      <div className="flex items-start justify-between mb-4">
        <div className={`w-12 h-12 ${classes.bg} rounded-lg flex items-center justify-center`}>
          <Icon className={`w-6 h-6 ${classes.icon}`} />
        </div>
      </div>
      <p className="text-sm text-gray-600 mb-2">{title}</p>
      <p className="text-3xl font-bold mb-2">{value.toLocaleString()}</p>
      <p className="text-xs text-gray-500">{description}</p>
    </div>
  );
}

'use client';

import { useEffect, useState } from 'react';
import axios from 'axios';
import { FileText, RefreshCw, AlertTriangle, CheckCircle, AlertCircle, MapPin } from 'lucide-react';
import type { IActivityLog } from '@mas/types';

export default function LogsPage() {
  const [logs, setLogs] = useState<IActivityLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchLogs = async () => {
      try {
        const response = await axios.get(
          `${process.env.NEXT_PUBLIC_API_URL}/audit-logs?limit=50`,
        );
        setLogs(response.data || []);
        setError(null);
      } catch (error) {
        console.error('Failed to fetch logs:', error);
        setError('Failed to load activity logs');
        setLogs([]);
      } finally {
        setLoading(false);
      }
    };

    fetchLogs();
  }, []);

  if (loading) {
    return (
      <div className="space-y-8">
        <div className="page-header">
          <div className="px-8 py-6">
            <div className="flex items-center gap-3 mb-2">
              <FileText className="w-8 h-8 text-blue-600" />
              <div className="page-title">Activity Logs</div>
            </div>
            <p className="page-description">Recent system activity and attendance records</p>
          </div>
        </div>
        <div className="px-8 pb-8">
          <div className="card">
            <div className="card-body flex flex-col items-center justify-center h-64">
              <RefreshCw className="w-12 h-12 text-blue-600 animate-spin mb-4" />
              <p className="text-gray-600">Loading activity logs...</p>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-8">
        <div className="page-header">
          <div className="px-8 py-6">
            <div className="flex items-center gap-3 mb-2">
              <FileText className="w-8 h-8 text-blue-600" />
              <div className="page-title">Activity Logs</div>
            </div>
            <p className="page-description">Recent system activity and attendance records</p>
          </div>
        </div>
        <div className="px-8 pb-8">
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
          <div className="flex items-center gap-3 mb-2">
            <FileText className="w-8 h-8 text-blue-600" />
            <div className="page-title">Activity Logs</div>
          </div>
          <p className="page-description">Recent system activity and attendance records</p>
        </div>
      </div>

      {/* Main Content */}
      <div className="px-8 pb-8">
        <div className="card">
          <div className="card-header flex items-center justify-between">
            <h2 className="text-lg font-semibold">Recent Activity</h2>
            <span className="text-sm text-gray-600">{logs.length} records</span>
          </div>

          <div className="overflow-x-auto">
            <table className="table">
              <thead>
                <tr>
                  <th>Timestamp</th>
                  <th>NRP / Name</th>
                  <th>Status</th>
                  <th>Detection</th>
                  <th>Location</th>
                </tr>
              </thead>
              <tbody>
                {logs.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="px-6 py-8 text-center text-gray-500">
                      No activity logs found
                    </td>
                  </tr>
                ) : (
                  logs.map((log) => (
                    <tr key={log.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 text-sm text-gray-700 whitespace-nowrap">
                        {new Date(log.timestamp).toLocaleString()}
                      </td>
                      <td className="px-6 py-4 font-medium">{log.userId}</td>
                      <td className="px-6 py-4">
                        <span
                          className={`badge ${
                            log.attendanceStatus === 'present'
                              ? 'badge-success'
                              : 'badge-warning'
                          }`}
                        >
                          {log.attendanceStatus === 'present' ? (
                            <CheckCircle className="w-4 h-4 inline-block mr-1" />
                          ) : (
                            <AlertCircle className="w-4 h-4 inline-block mr-1" />
                          )}
                          {log.attendanceStatus}
                        </span>
                      </td>
                      <td className="px-6 py-4">
                        <span
                          className={`badge ${
                            log.detectionStatus === 'normal'
                              ? 'badge-gray'
                              : 'badge-danger'
                          }`}
                        >
                          {log.detectionStatus}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-600">
                        <MapPin className="w-4 h-4 inline-block mr-1" />
                        {log.latitude.toFixed(4)}, {log.longitude.toFixed(4)}
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}

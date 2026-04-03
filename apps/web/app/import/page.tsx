'use client';

import { useState } from 'react';
import axios from 'axios';
import { Upload, CheckCircle, AlertTriangle, FileUp, RefreshCw } from 'lucide-react';
import type { IBulkUserData, ImportMode } from '@mas/types';

export default function ImportPage() {
  const [mode, setMode] = useState<ImportMode>('skip_duplicates');
  const [users, setUsers] = useState<IBulkUserData[]>([]);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(
    null,
  );

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    try {
      // Check file type
      if (!['text/csv', '.csv', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'].includes(file.type) && !file.name.endsWith('.csv')) {
        setMessage({ type: 'error', text: 'Please upload a CSV or XLSX file' });
        return;
      }

      // Basic CSV parsing
      const text = await file.text();
      const lines = text.trim().split('\n').filter(line => line.trim());
      
      if (lines.length < 2) {
        setMessage({ type: 'error', text: 'CSV file must have header row and at least one data row' });
        return;
      }

      const header = lines[0].toLowerCase().split(',');
      const parsed: IBulkUserData[] = [];

      for (let i = 1; i < lines.length; i++) {
        const values = lines[i].split(',').map(v => v.trim());
        if (values.length === header.length && values.some(v => v)) {
          parsed.push({
            nrp: values[0] || '',
            name: values[1] || '',
            rank: values[2] || '',
            unit: values[3] || '',
            pin: values[4] || '',
          });
        }
      }

      if (parsed.length === 0) {
        setMessage({ type: 'error', text: 'No valid records found in CSV' });
        return;
      }

      setUsers(parsed);
      setMessage({ type: 'success', text: `Loaded ${parsed.length} records` });
    } catch (error) {
      console.error('File upload error:', error);
      setMessage({ type: 'error', text: 'Failed to parse CSV file' });
    }
  };

  const handleImport = async () => {
    setLoading(true);
    try {
      const response = await axios.post(
        `${process.env.NEXT_PUBLIC_API_URL}/import/users`,
        { users, mode, userId: 'admin' },
      );

      setMessage({
        type: 'success',
        text: `Import completed: ${response.data.successCount} success, ${response.data.failureCount} failed`,
      });
      setUsers([]);
    } catch (error) {
      setMessage({
        type: 'error',
        text: 'Import failed. Please try again.',
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-8">
      {/* Page Header */}
      <div className="page-header">
        <div className="px-8 py-6">
          <div className="flex items-center gap-3 mb-2">
            <FileUp className="w-8 h-8 text-blue-600" />
            <div className="page-title">Bulk Import</div>
          </div>
          <p className="page-description">Import personnel data from CSV files</p>
        </div>
      </div>

      {/* Main Content */}
      <div className="px-8 pb-8">
        <div className="max-w-2xl">
          <div className="card">
            {/* Import Mode */}
            <div className="card-body">
              <div className="mb-6">
                <label className="form-label">Import Mode</label>
                <select
                  value={mode}
                  onChange={(e) => setMode(e.target.value as ImportMode)}
                  className="form-input"
                >
                  <option value="skip_duplicates">Skip Duplicates (Recommended)</option>
                  <option value="overwrite">Overwrite Existing Records</option>
                </select>
              </div>

              {/* File Upload */}
              <div className="mb-6">
                <label className="form-label">CSV File Upload</label>
                <div className="relative">
                  <input
                    type="file"
                    accept=".csv,.xlsx"
                    onChange={handleFileUpload}
                    className="form-input opacity-0 absolute w-full h-full cursor-pointer"
                  />
                  <div className="form-input flex items-center justify-center h-32 bg-blue-50 border-2 border-dashed border-blue-300 rounded-lg cursor-pointer hover:border-blue-400 hover:bg-blue-100 transition-colors">
                    <div className="text-center">
                      <Upload className="w-8 h-8 text-blue-600 mx-auto mb-2" />
                      <p className="text-sm text-gray-700 font-medium">Click to upload CSV file</p>
                      <p className="text-xs text-gray-500">or drag and drop</p>
                    </div>
                  </div>
                </div>
                <p className="text-xs text-gray-500 mt-2">
                  Expected columns: NRP, Name, Rank, Unit, PIN
                </p>
              </div>

              {/* Messages */}
              {message && (
                <div className={`alert mb-6 ${message.type === 'success' ? 'alert-success' : 'alert-danger'}`}>
                  {message.type === 'success' ? (
                    <CheckCircle className="w-5 h-5 inline-block mr-2" />
                  ) : (
                    <AlertTriangle className="w-5 h-5 inline-block mr-2" />
                  )}
                  {message.text}
                </div>
              )}

              {/* Preview */}
              {users.length > 0 && (
                <div className="mb-6">
                  <div className="flex items-center justify-between mb-4">
                    <p className="text-sm font-medium text-gray-700">
                      Data Preview ({users.length} records)
                    </p>
                    <button
                      onClick={() => setUsers([])}
                      className="text-xs text-red-600 hover:text-red-700 underline"
                    >
                      Clear
                    </button>
                  </div>
                  <div className="overflow-x-auto border border-gray-200 rounded-lg">
                    <table className="table text-sm">
                      <thead>
                        <tr>
                          <th>NRP</th>
                          <th>Name</th>
                          <th>Rank</th>
                          <th>Unit</th>
                        </tr>
                      </thead>
                      <tbody>
                        {users.slice(0, 5).map((user, i) => (
                          <tr key={i}>
                            <td className="font-mono text-gray-700">{user.nrp}</td>
                            <td>{user.name}</td>
                            <td>{user.rank}</td>
                            <td>{user.unit}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                    {users.length > 5 && (
                      <p className="text-xs text-gray-500 p-3 border-t border-gray-200">
                        ... and {users.length - 5} more records
                      </p>
                    )}
                  </div>
                </div>
              )}

              {/* Import Button */}
              <button
                onClick={handleImport}
                disabled={loading || users.length === 0}
                className={`btn btn-primary w-full ${loading || users.length === 0 ? 'opacity-50 cursor-not-allowed' : ''}`}
              >
                {loading ? (
                  <>
                    <RefreshCw className="w-4 h-4 inline-block mr-2 animate-spin" />
                    Importing...
                  </>
                ) : (
                  <>
                    <Upload className="w-4 h-4 inline-block mr-2" />
                    Import {users.length > 0 ? `${users.length} Users` : 'Users'}
                  </>
                )}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

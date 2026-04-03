'use client';

import { useEffect, useState } from 'react';
import axios from 'axios';
import { Settings, RefreshCw, CheckCircle, AlertTriangle, Lock, Zap, MapPin } from 'lucide-react';
import type { ISystemConfigValue } from '@mas/types';

export default function SettingsPage() {
  const [config, setConfig] = useState<ISystemConfigValue | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    const fetchConfig = async () => {
      try {
        const response = await axios.get(
          `${process.env.NEXT_PUBLIC_API_URL}/config/system`,
        );
        setConfig(response.data);
        setError(null);
      } catch (error) {
        console.error('Failed to fetch config:', error);
        setError('Failed to load configuration');
      } finally {
        setLoading(false);
      }
    };

    fetchConfig();
  }, []);

  const handleSave = async () => {
    if (!config) return;

    try {
      await axios.put(
        `${process.env.NEXT_PUBLIC_API_URL}/config/system`,
        config,
      );
      setSaved(true);
      setError(null);
      setTimeout(() => setSaved(false), 3000);
    } catch (error) {
      console.error('Failed to save config:', error);
      setError('Failed to save configuration');
    }
  };

  if (loading) {
    return (
      <div className="space-y-8">
        <div className="page-header">
          <div className="px-8 py-6">
            <div className="flex items-center gap-3 mb-2">
              <Settings className="w-8 h-8 text-blue-600" />
              <div className="page-title">System Settings</div>
            </div>
            <p className="page-description">Configure system parameters and security settings</p>
          </div>
        </div>
        <div className="px-8 pb-8">
          <div className="card">
            <div className="card-body flex flex-col items-center justify-center h-64">
              <RefreshCw className="w-12 h-12 text-blue-600 animate-spin mb-4" />
              <p className="text-gray-600">Loading settings...</p>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (error && !config) {
    return (
      <div className="space-y-8">
        <div className="page-header">
          <div className="px-8 py-6">
            <div className="flex items-center gap-3 mb-2">
              <Settings className="w-8 h-8 text-blue-600" />
              <div className="page-title">System Settings</div>
            </div>
            <p className="page-description">Configure system parameters and security settings</p>
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

  if (!config) {
    return (
      <div className="space-y-8">
        <div className="page-header">
          <div className="px-8 py-6">
            <div className="flex items-center gap-3 mb-2">
              <Settings className="w-8 h-8 text-blue-600" />
              <div className="page-title">System Settings</div>
            </div>
            <p className="page-description">Configure system parameters and security settings</p>
          </div>
        </div>
        <div className="px-8 pb-8">
          <div className="alert alert-warning">
            <AlertTriangle className="w-5 h-5 inline-block mr-2" />
            Failed to load configuration
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
            <Settings className="w-8 h-8 text-blue-600" />
            <div className="page-title">System Settings</div>
          </div>
          <p className="page-description">Configure system parameters and security settings</p>
        </div>
      </div>

      {/* Main Content */}
      <div className="px-8 pb-8">
        {error && (
          <div className="alert alert-danger mb-6">
            <AlertTriangle className="w-5 h-5 inline-block mr-2" />
            {error}
          </div>
        )}

        {saved && (
          <div className="alert alert-success mb-6">
            <CheckCircle className="w-5 h-5 inline-block mr-2" />
            Settings saved successfully!
          </div>
        )}

        <div className="max-w-3xl space-y-6">
          {/* Authentication Settings */}
          <div className="card">
            <div className="card-header flex items-center gap-2">
              <Lock className="w-5 h-5 text-blue-600" />
              <h2 className="text-lg font-semibold">Authentication</h2>
            </div>
            <div className="card-body">
              <div className="space-y-4">
                <label className="flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={config.auth.pin}
                    onChange={(e) =>
                      setConfig({
                        ...config,
                        auth: { ...config.auth, pin: e.target.checked },
                      })
                    }
                    className="form-checkbox"
                  />
                  <span className="ml-3 font-medium">PIN Authentication</span>
                  <span className="ml-2 text-sm text-gray-500">(NRP + PIN)</span>
                </label>
                <label className="flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={config.auth.otp}
                    onChange={(e) =>
                      setConfig({
                        ...config,
                        auth: { ...config.auth, otp: e.target.checked },
                      })
                    }
                    className="form-checkbox"
                  />
                  <span className="ml-3 font-medium">OTP Authentication</span>
                  <span className="ml-2 text-sm text-gray-500">(One-Time Password)</span>
                </label>
                <label className="flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    checked={config.auth.face}
                    onChange={(e) =>
                      setConfig({
                        ...config,
                        auth: { ...config.auth, face: e.target.checked },
                      })
                    }
                    className="form-checkbox"
                  />
                  <span className="ml-3 font-medium">Face Recognition</span>
                  <span className="ml-2 text-sm text-gray-500">(Biometric)</span>
                </label>
              </div>
            </div>
          </div>

          {/* Detection Settings */}
          <div className="card">
            <div className="card-header flex items-center gap-2">
              <Zap className="w-5 h-5 text-blue-600" />
              <h2 className="text-lg font-semibold">Detection Settings</h2>
            </div>
            <div className="card-body">
              <div>
                <label className="form-label">Detection Sensitivity Level</label>
                <select
                  value={config.detection.level}
                  onChange={(e) =>
                    setConfig({
                      ...config,
                      detection: {
                        ...config.detection,
                        level: e.target.value as 'low' | 'medium' | 'high',
                      },
                    })
                  }
                  className="form-input"
                >
                  <option value="low">Low - Less alerts, faster processing</option>
                  <option value="medium">Medium - Balanced sensitivity</option>
                  <option value="high">High - More alerts, thorough detection</option>
                </select>
                <p className="text-xs text-gray-500 mt-2">
                  Higher sensitivity may increase false positives but catches more anomalies
                </p>
              </div>
            </div>
          </div>

          {/* Location Settings */}
          <div className="card">
            <div className="card-header flex items-center gap-2">
              <MapPin className="w-5 h-5 text-blue-600" />
              <h2 className="text-lg font-semibold">Location Validation</h2>
            </div>
            <div className="card-body space-y-6">
              <div>
                <label className="form-label">Validation Mode</label>
                <select
                  value={config.geo.mode}
                  onChange={(e) =>
                    setConfig({
                      ...config,
                      geo: {
                        ...config.geo,
                        mode: e.target.value as 'hybrid' | 'gps' | 'network',
                      },
                    })
                  }
                  className="form-input"
                >
                  <option value="hybrid">Hybrid - GPS + Network (Most Accurate)</option>
                  <option value="gps">GPS Only - Precise outdoor location</option>
                  <option value="network">Network Only - Fast approximate location</option>
                </select>
              </div>
              <div>
                <label className="form-label">Validation Radius: {config.geo.radius} meters</label>
                <input
                  type="range"
                  min="10"
                  max="500"
                  step="10"
                  value={config.geo.radius}
                  onChange={(e) =>
                    setConfig({
                      ...config,
                      geo: { ...config.geo, radius: parseInt(e.target.value) },
                    })
                  }
                  className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-blue-600"
                />
                <div className="flex justify-between text-xs text-gray-500 mt-2">
                  <span>10m (Very strict)</span>
                  <span>500m (Very loose)</span>
                </div>
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="flex gap-3">
            <button
              onClick={handleSave}
              className="btn btn-primary flex-1 flex items-center justify-center gap-2"
            >
              <CheckCircle className="w-4 h-4" />
              Save Configuration
            </button>
            <button
              onClick={() => window.location.reload()}
              className="btn btn-secondary flex-1 flex items-center justify-center gap-2"
            >
              <RefreshCw className="w-4 h-4" />
              Reset
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

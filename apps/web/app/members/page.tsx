'use client';

import { useState, useEffect } from 'react';
import axios from 'axios';
import { Users, RefreshCw, AlertTriangle, Search } from 'lucide-react';
import type { IUser } from '@mas/types';

export default function MembersPage() {
  const [members, setMembers] = useState<IUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    const fetchMembers = async () => {
      try {
        const response = await axios.get(
          `${process.env.NEXT_PUBLIC_API_URL}/device/list`,
        );
        setMembers(response.data || []);
        setError(null);
      } catch (error) {
        console.error('Failed to fetch members:', error);
        setError('Failed to load members');
        setMembers([]);
      } finally {
        setLoading(false);
      }
    };

    fetchMembers();
  }, []);

  const filteredMembers = members.filter((member) =>
    member.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    member.nrp.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="space-y-8">
      {/* Page Header */}
      <div className="page-header">
        <div className="px-8 py-6">
          <div className="flex items-center gap-3 mb-2">
            <Users className="w-8 h-8 text-blue-600" />
            <div className="page-title">Members</div>
          </div>
          <p className="page-description">Manage personnel and monitor active members</p>
        </div>
      </div>

      {/* Main Content */}
      <div className="px-8 pb-8">
        {loading ? (
          <div className="card">
            <div className="card-body flex flex-col items-center justify-center h-64">
              <RefreshCw className="w-12 h-12 text-blue-600 animate-spin mb-4" />
              <p className="text-gray-600">Loading members...</p>
            </div>
          </div>
        ) : error ? (
          <div className="alert alert-danger">
            <AlertTriangle className="w-5 h-5 inline-block mr-2" />
            {error}
          </div>
        ) : (
          <div className="card">
            {/* Header with Search */}
            <div className="card-header flex items-center justify-between">
              <h2 className="text-lg font-semibold">Personnel List</h2>
              <span className="text-sm text-gray-600">{filteredMembers.length} members</span>
            </div>

            {/* Search Bar */}
            <div className="px-6 py-4 border-b border-gray-200">
              <div className="relative">
                <Search className="absolute left-3 top-3 text-gray-400 w-5 h-5" />
                <input
                  type="text"
                  placeholder="Search by name or NRP..."
                  className="form-input pl-10 w-full"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>
            </div>

            {/* Table */}
            <div className="overflow-x-auto">
              <table className="table">
                <thead>
                  <tr>
                    <th>NRP</th>
                    <th>Name</th>
                    <th>Rank</th>
                    <th>Unit</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredMembers.length === 0 ? (
                    <tr>
                      <td colSpan={5} className="px-6 py-8 text-center">
                        <p className="text-gray-500">
                          {searchTerm ? 'No members match your search' : 'No members found'}
                        </p>
                      </td>
                    </tr>
                  ) : (
                    filteredMembers.map((member) => (
                      <tr key={member.id} className="hover:bg-gray-50">
                        <td className="px-6 py-4 font-mono text-sm text-gray-700">{member.nrp}</td>
                        <td className="px-6 py-4 font-medium">{member.name}</td>
                        <td className="px-6 py-4 text-gray-700">{member.rank}</td>
                        <td className="px-6 py-4 text-gray-600">{member.unit}</td>
                        <td className="px-6 py-4">
                          <span
                            className={`badge ${
                              member.isActive ? 'badge-success' : 'badge-gray'
                            }`}
                          >
                            {member.isActive ? 'Active' : 'Inactive'}
                          </span>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

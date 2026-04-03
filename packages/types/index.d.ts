export interface IUser {
    id: string;
    nrp: string;
    name: string;
    rank: string;
    unit: string;
    pin: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
}
export interface IUserProfile extends Omit<IUser, 'pin'> {
}
export interface IDevice {
    id: string;
    userId: string;
    deviceId: string;
    deviceModel: string;
    osVersion: string;
    isActive: boolean;
    bindedAt: Date;
    lastSeen: Date;
}
export type DeviceMode = 'loose' | 'strict';
export type AttendanceStatus = 'present' | 'absent' | 'late' | 'early_leave';
export type DetectionStatus = 'normal' | 'suspicious' | 'blocked';
export interface IActivityLog {
    id: string;
    userId: string;
    deviceId: string;
    timestamp: Date;
    latitude: number;
    longitude: number;
    accuracy: number;
    attendanceStatus: AttendanceStatus;
    detectionStatus: DetectionStatus;
    detectionDetails?: string;
    ipAddress: string;
    userAgent: string;
    isVerified: boolean;
}
export interface IQRToken {
    id: string;
    token: string;
    isActive: boolean;
    expiresAt: Date;
    createdAt: Date;
}
export interface ISystemConfigValue {
    auth: {
        pin: boolean;
        otp: boolean;
        face: boolean;
    };
    device: {
        mode: DeviceMode;
    };
    geo: {
        mode: 'hybrid' | 'gps' | 'network';
        radius: number;
    };
    qr: {
        refresh: number;
    };
    detection: {
        level: 'low' | 'medium' | 'high';
    };
}
export interface IBulkUserData {
    nrp: string;
    name: string;
    rank: string;
    unit: string;
    pin: string;
}
export type ImportMode = 'overwrite' | 'skip_duplicates';
export interface IImportLog {
    id: string;
    mode: ImportMode;
    totalRecords: number;
    successCount: number;
    failureCount: number;
    errors: string[];
    createdAt: Date;
    importedBy: string;
}
export interface IAttendanceStats {
    totalMembers: number;
    presentCount: number;
    absentCount: number;
    lateCount: number;
    suspiciousCount: number;
    blockedCount: number;
    lastUpdated: Date;
}
export interface ApiResponse<T> {
    success: boolean;
    data?: T;
    error?: string;
    timestamp: Date;
}
export interface PaginatedResponse<T> {
    data: T[];
    total: number;
    page: number;
    pageSize: number;
    totalPages: number;
}
export interface DetectionContext {
    userId: string;
    latitude: number;
    longitude: number;
    accuracy: number;
    timestamp: Date;
    previousActivity?: IActivityLog;
}
export interface DetectionResult {
    status: DetectionStatus;
    confidence: number;
    reason: string;
    details: {
        locationJump?: boolean;
        rapidScan?: boolean;
        deviceSwitch?: boolean;
        suspiciousPattern?: boolean;
    };
}
export interface WebSocketMessage {
    event: string;
    data: any;
    timestamp: Date;
}
export interface DashboardUpdate {
    stats: IAttendanceStats;
    recentActivities: IActivityLog[];
    activeMembers: number;
    inactiveMembers: number;
}
//# sourceMappingURL=index.d.ts.map